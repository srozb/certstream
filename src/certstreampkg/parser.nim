import jsony

type 
  Extensions* = object
    authorityInfoAccess: string
    authorityKeyIdentifier: string
    basicConstraints: string
    certificatePolicies: string
    ctlSignedCertificateTimestamp: string
    extendedKeyUsage: string
    keyUsage: string
    subjectAltName: string
    subjectKeyIdentifier: string
  Issuer* = object
    C: string
    CN: string
    L: string
    O: string
    OU: string
    ST: string
    aggregated: string
    emailAddress: string
  Subject* = object
    C: string
    CN: string
    L: string
    O: string
    OU: string
    ST: string
    aggregated: string
    emailAddress: string
  LeafCert* = object
    all_domains*: seq[string]
    extensions: Extensions
    fingerprint: string
    issuer: Issuer
    not_after: Natural
    not_before: Natural
    serial_number: string
    signature_algorithm: string
    subject: Subject
  Source* = object
    name: string
    url: string
  Data* = object
    cert_index: Natural
    cert_link: string
    leaf_cert*: LeafCert
    seen: float
    source: Source
    update_type: string
  Record* = object
    data*: Data

proc `$`*(d: Data): string = d.toJson()
proc parseMsg*(msg: string): Record = msg.fromJson(Record)


