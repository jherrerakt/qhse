class TipoError {
  String sCodigo;
  String sMensaje;

  TipoError(this.sCodigo, this.sMensaje);

  String get codigo => this.sCodigo;
  String get mensaje => this.sMensaje;
}
