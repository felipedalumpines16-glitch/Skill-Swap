String userFacingError(Object error) {
  if (error is UnsupportedError) {
    return error.message ?? 'This action is unavailable in offline demo mode.';
  }
  if (error is ArgumentError) {
    return error.message?.toString() ?? 'Check the information and try again.';
  }
  if (error is StateError) return error.message.toString();
  return 'Something went wrong. Please try again.';
}
