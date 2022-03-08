/**
 * How to use:
 *  - yarn execute <NETWORK> ./setup/add_new_multi_giveaway.ts <GIVEAWAY_CONTRACT> <GIVEAWAY_NAME>
 *
 * GIVEAWAY_CONTRACT: from data/giveaways/multi_giveaway_1/detective_letty.json then the giveaway contract is: Multi_Giveaway_1
 * GIVEAWAY_NAME: from data/giveaways/multi_giveaway_1/detective_letty.json then the giveaway name is: detective_letty
 */
import fs from 'fs-extra';

import {createClaimMerkleTree} from './helper/getClaims';
import helpers, {MultiClaim} from './helper/merkleTreeHelper';
const {calculateMultiClaimHash} = helpers;

const args      = process.argv.slice(2);
const network   = args[0];
const claimFile = args[1];
const salt      = args[2];

const func = async function () {
  let claimData: MultiClaim[];
  try {
    claimData = fs.readJSONSync(
      `../data/${network}/${claimFile}_${salt}.json`
    );
  } catch (e) {
    console.log('Error', e);
    return;
  }

  const {merkleRootHash, saltedClaims, tree} = createClaimMerkleTree(
    claimData,
    salt
  );

  const contractAddresses: string[] = [];
  const addAddress = (address: string) => {
    address = address.toLowerCase();
    if (!contractAddresses.includes(address)) contractAddresses.push(address);
  };
  claimData.forEach((claim) => {
    claim.erc1155.forEach((erc1155) => addAddress(erc1155.contractAddress));
    claim.erc721.forEach((erc721) => addAddress(erc721.contractAddress));
    claim.erc20.contractAddresses.forEach((erc20) => addAddress(erc20));
  });

  const claimsWithProofs: (MultiClaim & {proof: string[]})[] = [];
  for (const claim of saltedClaims) {
    claimsWithProofs.push({
      ...claim,
      proof: tree.getProof(calculateMultiClaimHash(claim)),
    });
  }
  const basePath = `../data/multi-claim/${network}`;
  const proofPath = `${basePath}/.multi_claims_proofs_${network}_${claimFile}.json`;
  const rootHashPath = `${basePath}/.multi_claims_root_hash_${network}_${claimFile}.json`;
  fs.outputJSONSync(proofPath, claimsWithProofs);
  fs.outputFileSync(rootHashPath, merkleRootHash);
  console.log(`Proofs at: ${proofPath}`);
  console.log(`Hash at: ${rootHashPath}`);
};
export default func;

if (require.main === module) {
  func();
}
