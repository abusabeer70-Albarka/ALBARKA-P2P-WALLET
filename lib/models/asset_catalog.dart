import 'wallet_asset.dart';

class AssetCatalog {
  static const WalletAsset ethereum = WalletAsset(
    name: 'Ethereum',
    symbol: 'ETH',
    network: 'Ethereum',
    type: AssetType.native,
    logoAsset: 'assets/images/coins/eth.png',
    decimals: 18,
  );

  static const WalletAsset bitcoin = WalletAsset(
    name: 'Bitcoin',
    symbol: 'BTC',
    network: 'Bitcoin',
    type: AssetType.native,
    logoAsset: 'assets/images/coins/btc.png',
    decimals: 8,
  );

  static const WalletAsset bnb = WalletAsset(
    name: 'BNB',
    symbol: 'BNB',
    network: 'BNB Smart Chain',
    type: AssetType.native,
    logoAsset: 'assets/images/coins/bnb.png',
    decimals: 18,
  );

  static const WalletAsset solana = WalletAsset(
    name: 'Solana',
    symbol: 'SOL',
    network: 'Solana',
    type: AssetType.native,
    logoAsset: 'assets/images/coins/sol.png',
    decimals: 9,
  );

  static const WalletAsset ton = WalletAsset(
    name: 'Toncoin',
    symbol: 'TON',
    network: 'TON',
    type: AssetType.native,
    logoAsset: 'assets/images/coins/ton.png',
    decimals: 9,
  );

  static const WalletAsset tron = WalletAsset(
    name: 'TRON',
    symbol: 'TRX',
    network: 'TRON',
    type: AssetType.native,
    logoAsset: 'assets/images/coins/trx.png',
    decimals: 6,
  );

  static const WalletAsset usdt = WalletAsset(
    name: 'Tether USD',
    symbol: 'USDT',
    network: 'Ethereum',
    type: AssetType.erc20,
    contractAddress:
        '0xcF8bc22eF342820C3Bceb7202F987075Cef1c859',
    logoAsset: 'assets/images/coins/usdt.png',
    decimals: 6,
  );

  static const List<WalletAsset> defaultAssets = [
    ethereum,
    bitcoin,
    bnb,
    solana,
    ton,
    tron,
    usdt,
  ];
}
