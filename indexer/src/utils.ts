export const nodeURL = `http://127.0.0.1:8545`;

export type BlockData = {
  transactions: any[];
  [key: string]: any; 
};

export type ReceiptData = {
  [key: string]: any;
};

export async function getBlock(number: number) {
  const response = await fetch(nodeURL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: 1,
      method: "eth_getBlockByNumber",
      params: [`0x${number.toString(16)}`, true],
    }),
  });

  const data = await response.json();
  return data.result;
}

export async function getBlockReceipts(number: number) {
  const response = await fetch(nodeURL, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      jsonrpc: "2.0",
      id: 1,
      method: "eth_getBlockReceipts",
      params: [`0x${number.toString(16)}`],
    }),
  });

  const data = await response.json();
  return data.result;
}

export function convertBlockData(block: BlockData): BlockData {
  const convertedBlock: BlockData = { ...block };
  
  convertedBlock.number = parseInt(block.number.toString(), 16);
  convertedBlock.timestamp = new Date(parseInt(block.timestamp, 16) * 1000).toISOString();

  convertedBlock.transactions = block.transactions.map(tx => ({
    ...tx,
    blockNumber: parseInt(tx.blockNumber.toString(), 16),
    blockTimestamp: convertedBlock.timestamp,
  }));

  return convertedBlock;
}

export function convertReceiptData(receipt: ReceiptData, blockTimestamp: string): ReceiptData {
  return {
    ...receipt,
    blockNumber: parseInt(receipt.blockNumber.toString(), 16),
    blockTimestamp: blockTimestamp,
  };
}
