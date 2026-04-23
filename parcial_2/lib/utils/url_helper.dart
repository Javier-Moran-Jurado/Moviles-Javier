String getFullLogoUrl(String? logoPath) {
  if (logoPath == null || logoPath.isEmpty) return '';
  if (logoPath.startsWith('http')) return logoPath;
  if (logoPath.startsWith('file://')) {
    logoPath = logoPath.substring(7);
  }
  if (logoPath.isEmpty) return '';
  const base = 'https://parking.visiontic.com.co';
  if (logoPath.startsWith('/storage/') || logoPath.startsWith('/')) {
    return '$base$logoPath';
  }
  return '$base/storage/$logoPath';
}