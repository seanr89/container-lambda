const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");
const { S3Client, GetObjectCommand, PutObjectCommand, CopyObjectCommand, DeleteObjectCommand } = require("@aws-sdk/client-s3");
const client = new S3Client({}); // Initialize S3 Client
const sqsClient = new SQSClient({ region: process.env.AWS_REGION ?? 'eu-west-1' });

/**
 * A helper function to simulate an asynchronous operation (like fetching data)
 * @param {number} value - The value to return after the delay.
 * @returns {Promise<number>} - A promise that resolves with the value after 1 second.
 */
const delay = (timeout) => {
  return new Promise(resolve => {
    setTimeout(() => {
      console.log(`Processing delay: ${timeout}ms completed.`);
      resolve(timeout * 2); // Simulating an asynchronous calculation
    }, timeout);
  });
};

// Helper function to read the full file content from S3
async function getCsvContent(bucketName, key) {
    console.log(`Attempting to retrieve s3://${bucketName}/${key}`);
    
    const command = new GetObjectCommand({
        Bucket: bucketName,
        Key: key,
    });

    try {
        const response = await client.send(command);
        
        // Read the stream and return content as a string
        return new Promise((resolve, reject) => {
            const chunks = [];
            response.Body.on('data', (chunk) => chunks.push(chunk));
            response.Body.once('end', () => resolve(Buffer.concat(chunks).toString('utf8')));
            response.Body.once('error', reject);
        });
        
    } catch (error) {
        console.error("Error reading from S3:", error);
        throw new Error(`Failed to read CSV from S3: ${error.message}`);
    }
}

/**
 * Splits a CSV string into a specified number of chunks, preserving the header in each.
 * @param {string} csvContent - The full content of the CSV file.
 * @param {number} numChunks - The desired number of chunks (e.g., 5).
 * @returns {Array<string>} An array of CSV strings, each representing a chunk.
 */
function splitCsv(csvContent, numChunks) {
    // 1. Split the content into lines and filter out empty lines caused by trailing newlines
    const lines = csvContent.split(/\r?\n/).filter(line => line.trim().length > 0);

    if (lines.length === 0) {
        console.warn("Input CSV file is empty.");
        return [];
    }
    
    // 2. Extract the header and data rows
    const header = lines[0];
    const dataRows = lines.slice(1);
    
    const totalDataRows = dataRows.length;
    
    if (totalDataRows === 0) {
        // Handle case where file only contains a header
        console.warn("CSV file only contains a header. Returning 1 chunk with only the header.");
        return [header];
    }
    
    // 3. Calculate the size of each chunk (using Math.ceil to distribute remainder)
    const chunkSize = Math.ceil(totalDataRows / numChunks);
    
    const chunks = [];
    
    // 4. Loop to create the chunks
    for (let i = 0; i < numChunks; i++) {
        // Calculate the start and end index for slicing the data rows
        const start = i * chunkSize;
        // The end index ensures the last chunk gets any remainder rows
        const end = Math.min(start + chunkSize, totalDataRows);
        
        // Get the specific data rows for this chunk
        const chunkData = dataRows.slice(start, end);
        
        // Stop if we have processed all rows (prevents empty chunks if numChunks > totalDataRows)
        if (chunkData.length === 0 && start > 0) {
            break; 
        }

        // 5. Construct the final chunk content: Header + Newline + Data Rows
        const chunkContent = header + '\n' + chunkData.join('\n');
        
        chunks.push(chunkContent);
        
        console.log(`Generated Chunk ${i + 1}: ${chunkData.length} data rows (${chunkContent.length} bytes)`);
    }

    return chunks;
}


module.exports.handler = async (event) => {
  const bucket = event.Records[0].s3.bucket.name;
  const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
  const trimmedKey = key.replace('inbound/', '');
  console.log(`just the entire event: ${JSON.stringify(event)}`);
  try{
    const numChunks = 5; // The required number of chunks
    // --- 2. Read the entire CSV content ---
    const csvContent = await getCsvContent(bucket, key);
    // --- 3. Split the content into chunks ---
    const csvChunks = splitCsv(csvContent, numChunks);

    for (let i = 0; i < csvChunks.length; i++) {
      const key = `chunks/processed/${trimmedKey.replace('.csv', '')}_chunk_${i + 1}.csv`;
      console.log(`Uploading chunk ${i + 1} to s3://${bucket}/${key}`);
      // In a real Lambda, you would use PutObjectCommand here to upload the chunk:
      await client.send(new PutObjectCommand({
          Bucket: bucket,
          Key: key,
          Body: csvChunks[i],
          ContentType: 'text/csv'
      }));
      await delay(1500); // Simulate some processing delay

      const message = {
        bucket,
        key,
        message: "Chunked file processed successfully"
      };
      console.log(`Sending message for chunk ${i + 1} to SQS: ${JSON.stringify(message)}`);

      const command = new SendMessageCommand({
        QueueUrl: process.env.SQS_QUEUE_URL,
        MessageBody: JSON.stringify(message),
      });
      await sqsClient.send(command);
    }
    console.log("All chunks processed successfully.");

    // Lets move the S3 triggered file to an archive folder!
    const archiveKey = `archive/${trimmedKey}`;
    await client.send(new CopyObjectCommand({
        Bucket: bucket,
        CopySource: `${bucket}/${key}`,
        Key: archiveKey
    }));
    await client.send(new DeleteObjectCommand({
        Bucket: bucket,
        Key: key
    }));

    return {
        statusCode: 200,
        body: JSON.stringify({ 
            message: `${csvChunks.length} chunks generated and processed.`
        }),
    };
    
  } catch (error) {
    console.error("Error processing CSV:", error);
    return {
        statusCode: 500,
        body: JSON.stringify({ 
            message: 'Failed to process CSV file.', 
            error: error.message 
        }),
    };
  }
};