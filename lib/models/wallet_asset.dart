enum AssetType {
  native,
  erc20,
}

class WalletAsset {
  final String name;
  final String symbol;
  final String network;
  final AssetType type;
  final String? contractAddress;
  final String logoAsset;
  final int decimals;

  const WalletAsset({
    required this.name,
    required this.symbol,
    required this.network,
    required this.type,
    required this.logoAsset,
    required this.decimals,
    this.contractAddress,
  });

  bool get isNative => type == AssetType.native;
  bool get isToken => type == AssetType.erc20;
}
