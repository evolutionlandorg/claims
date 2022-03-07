JSON format:

```json
[
  {
    "to": "0x9E7A5b836Da4d55D681Eed4495370e96295c785f", // recipient of the assets
    "erc1155": [
      {
        "ids": [
          // array of asset id
          "106914169990095390281037231343508379541260342522117732053367995686304065005572",
          "106914169990095390281037231343508379541260342522117732053367995686304065005568"
        ],
        "values": [
          // array of amount for each asset id
          1,
          1
        ],
        "contractAddress": "0xa342f5D851E866E18ff98F351f2c6637f4478dB5" // address of asset contract (most of the time our contract 0xa342f5D851E866E18ff98F351f2c6637f4478dB5)
      }
    ],
    "erc721": [], // empty
    "erc20": {
      // empty
      "amounts": [],
      "contractAddresses": []
    }
  }
]
```
