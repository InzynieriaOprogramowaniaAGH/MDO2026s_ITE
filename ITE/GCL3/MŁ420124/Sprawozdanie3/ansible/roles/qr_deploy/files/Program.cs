using Genocs.QRCodeGenerator.Encoder;
using System.IO;

var generator = new QRCodeGenerator();
var data = generator.CreateQrCode("https://jenkins.io", QRCodeGenerator.ECCLevel.Q);
var qr = new BitmapByteQRCode(data);
byte[] bmpBytes = qr.GetGraphic(5);
Directory.CreateDirectory("/output");
File.WriteAllBytes("/output/qrcode.bmp", bmpBytes);
System.Console.WriteLine("QR code generated successfully.");