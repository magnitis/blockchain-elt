import fs from 'fs/promises';
import path from 'path';
import {
  getBlock, 
  getBlockReceipts, 
  BlockData, 
  ReceiptData, 
  convertBlockData, 
  convertReceiptData 
} 
  from "./utils.js";



async function processBlock(blockNumber: number, blockFilePath: string, txFilePath: string, receiptFilePath: string): Promise<void> {
  const rawBlock = await getBlock(blockNumber);
  // Process block data
  const convertedBlock = convertBlockData(rawBlock as BlockData);

  // Save blocks
  const blockJsonl = JSON.stringify(convertedBlock) + '\n';
  await fs.appendFile(blockFilePath, blockJsonl);

  // Save transactions
  const txs = convertedBlock.transactions;
  if (txs.length > 0) {
    const txsJsonl = txs.map(tx => JSON.stringify(tx)).join('\n') + '\n';
    await fs.appendFile(txFilePath, txsJsonl);
  }

  // Process and save receipts
  const rawReceipts = await getBlockReceipts(blockNumber);
  if (rawReceipts && rawReceipts.length > 0) {
    const convertedReceipts = rawReceipts.map((receipt: ReceiptData) => 
      convertReceiptData(receipt as ReceiptData, convertedBlock.timestamp)
    );
    const receiptsJsonl = convertedReceipts.map((receipt: ReceiptData) => JSON.stringify(receipt)).join('\n') + '\n';
    await fs.appendFile(receiptFilePath, receiptsJsonl);
  }
}

async function batchProcessBlocks(startBlock: number, endBlock: number, batchSize: number): Promise<void> {
  const dataDir = './db/user_files/';

  const blockFilePath = path.join(dataDir, `blocks_${startBlock}_${endBlock}.jsonl`);
  const txFilePath = path.join(dataDir, `transactions_${startBlock}_${endBlock}.jsonl`);
  const receiptFilePath = path.join(dataDir, `receipts_${startBlock}_${endBlock}.jsonl`);

  await fs.writeFile(blockFilePath, '');
  await fs.writeFile(txFilePath, '');
  await fs.writeFile(receiptFilePath, '');

  // Process blocks in batches
  for (let i = startBlock; i <= endBlock; i += batchSize) {
    const batchEnd = Math.min(i + batchSize - 1, endBlock);
    console.log(`Processing blocks ${i} to ${batchEnd}`);

    const promises = [];
    for (let blockNumber = i; blockNumber <= batchEnd; blockNumber++) {
      promises.push(processBlock(blockNumber, blockFilePath, txFilePath, receiptFilePath));
    }

    await Promise.all(promises);

  }

  console.log(`Saved block data to ${blockFilePath}`);
  console.log(`Saved transactions to ${txFilePath}`);
  console.log(`Saved receipts to ${receiptFilePath}`);
}

async function main(): Promise<void> {
  const startBlock = parseInt(process.env.START || '');
  const count = parseInt(process.env.COUNT || '');

  if (isNaN(startBlock) || isNaN(count)) {
    console.error('Error: Please provide valid START and COUNT environment variables.');
    process.exit(1);
  }

  const endBlock = startBlock + count;
  const batchSize = 100;

  console.log(`Processing blocks from ${startBlock} to ${endBlock}`);

  await batchProcessBlocks(startBlock, endBlock, batchSize);

  console.log("Batch processing completed");
}

main().catch(console.error);