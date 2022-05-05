from brownie import accounts, NFTMarketplace

def main():
    
    account = accounts.load('mywaalet')
    contract = NFTMarketplace.deploy({'from': account}, publish_source=True)
    
    print(f"Your NFT marketplace deployed at {contract} ")
    
    