create database KUTUPHANE
USE KUTUPHANE

create table Kitaplar (
KitapID int identity(1,1) primary key,
KitapAdi nvarchar(250),
Yazar nvarchar(250),
Yayinevi nvarchar(250),
BasimYili int,
StokMiktari int
)

create table Uyeler (
UyeID int identity(1,1) primary key,
UyeAdi nvarchar(250),
UyeSoyadi nvarchar(250),
TelefonNo varchar(15),
Email nvarchar(50)
)
ALTER TABLE Uyeler
ADD CONSTRAINT PK_Uyeler PRIMARY KEY (UyeID);

create table OduncAlmalar (
OduncID int identity(1,1) primary key,
KitapID int foreign key references Kitaplar(KitapID),
UyeID int foreign key references Uyeler(UyeID),
OduncAlmaTarihi date,
TeslimTarihi date
)

insert into Kitaplar (KitapAdi, Yazar, Yayinevi, BasimYili, StokMiktari)
values
('Dijital Dedektifler','Orhan Tokel','Acayip', 2024, 25),
('Zihnini Yeniden Yapýlandýr', 'Volkan Erkan','Destek Yayýnlarý', 2020, 30),
('Savaþ ve Barýþ', 'Lev Tolstoy', 'Can Yayýnlarý', 2005, 10),
( 'Suç ve Ceza', 'Fyodor Dostoyevski', 'Ýþ Bankasý', 2010, 7),
( 'Þeker Portakalý', 'José Mauro de Vasconcelos', 'Can Yayýnlarý', 2008, 12),
( 'Yabancý', 'Albert Camus', 'Can Yayýnlarý', 2012, 5),
( '1984', 'George Orwell', 'Alfa Yayýnlarý', 2015, 8),
( 'Hayvan Çiftliði', 'George Orwell', 'Alfa Yayýnlarý', 2016, 9),
( 'Küçük Prens', 'Antoine de Saint-Exupéry', 'Mavi Bulut', 2011, 15),
( 'Dava', 'Franz Kafka', 'Ýþ Bankasý', 2018, 6),
( 'Çavdar Tarlasýnda Çocuklar', 'J.D. Salinger', 'Yapý Kredi', 2009, 4),
( 'Ýnce Memed', 'Yaþar Kemal', 'Yapý Kredi', 2013, 10);

insert into Uyeler(UyeAdi, UyeSoyadi, TelefonNo, Email)
values
('Ali', 'Yýlmaz', '05331234567', 'ali.yilmaz@example.com'),
('Ayþe', 'Demir', '05339876543', 'ayse.demir@example.com'),
('Mehmet', 'Kaya', '05332345678', 'mehmet.kaya@example.com'),
('Fatma', 'Þahin', '05337654321', 'fatma.sahin@example.com'),
('Ahmet', 'Arslan', '05331239876', 'ahmet.arslan@example.com'),
('Elif', 'Yýldýz', '05332146789', 'elif.yildiz@example.com'),
('Hasan', 'Çelik', '05337894561', 'hasan.celik@example.com'),
('Zeynep', 'Acar', '05336782345', 'zeynep.acar@example.com'),
('Murat', 'Öztürk', '05331234512', 'murat.ozturk@example.com'),
('Hakan', 'Güneþ', '05335678912', 'hakan.gunes@example.com')

declare @i int = 0
declare @OduncAlmaTarihi DATE;

while @i < = 1000
begin
set @OduncAlmaTarihi = DATEADD(DAY, -FLOOR(RAND()*365), GETDATE());
insert into OduncAlmalar(KitapID, UyeID, OduncAlmaTarihi, TeslimTarihi)
values
(FLOOR (RAND()*12) + 1,FLOOR (RAND()*12) + 1, @OduncAlmaTarihi,  DATEADD(DAY, 15, @OduncAlmaTarihi))

set @i = @i + 1
end

select count(*) from OduncAlmalar

/* Stored Procedure */
CREATE PROCEDURE OduncAlinanKitaplarTariheGore
  @BaslangicTarihi DATE,
  @BitisTarihi DATE
AS
BEGIN
  SELECT 
    OA.OduncID, 
    K.KitapAdi, 
    U.UyeAdi, 
    OA.OduncAlmaTarihi, 
    OA.TeslimTarihi
  FROM 
    OduncAlmalar OA
    JOIN Kitaplar K ON OA.KitapID = K.KitapID
    JOIN Uyeler U ON OA.UyeID = U.UyeID
  WHERE 
    OA.OduncAlmaTarihi BETWEEN @BaslangicTarihi AND @BitisTarihi
  ORDER BY 
    OA.OduncAlmaTarihi;
END;


EXEC OduncAlinanKitaplarTariheGore '2024-01-01', '2024-12-31';

CREATE PROCEDURE OduncAlmaStogaGore
    @kitapID INT,
    @uyeID INT
AS
BEGIN
    DECLARE @stok INT;

    
    BEGIN TRANSACTION;

    
    SELECT @stok = StokMiktari FROM Kitaplar WHERE KitapID = @kitapID;

    IF @stok > 0
    BEGIN
      
        INSERT INTO OduncAlmalar ( KitapID, UyeID, OduncAlmaTarihi, TeslimTarihi)
        VALUES ( @kitapID, @uyeID, GETDATE(),DATEADD(DAY, 15, GETDATE()));

        
        UPDATE Kitaplar SET StokMiktari = StokMiktari - 1 WHERE KitapID = @kitapID

        COMMIT TRANSACTION;
        
        PRINT 'Ödünç alma iþlemi baþarýlý';
    END
    ELSE
    BEGIN
        ROLLBACK TRANSACTION;

        PRINT 'Stok yok, ödünç alma iþlemi yapýlamaz';
    END
END;

EXEC OduncAlmaStogaGore @kitapID = 3, @uyeID = 1;

CREATE PROCEDURE UyeBilgileriniGuncelle
  @UyeID INT,
  @YeniUyeAdi NVARCHAR(50),
  @YeniUyeSoyadi NVARCHAR (100),
  @YeniUyeTelefonu NVARCHAR(15),
  @YeniUyeEmail NVARCHAR(50)
AS
BEGIN
  UPDATE Uyeler
  SET 
    UyeAdi = @YeniUyeAdi,
	UyeSoyadi = @YeniUyeSoyadi,
    TelefonNo = @YeniUyeTelefonu,
    Email = @YeniUyeEmail
  WHERE 
    UyeID = @UyeID;
END;


EXEC UyeBilgileriniGuncelle 2, 'Ali', 'Hür', '5555786954', 'ali.hur@example.com';

/* Log Tablosu ve Trigger */


create table LOG_TABLOSU(
 
 LogID int identity(1,1) primary key,
 KitapID int,
 IslemTipi nvarchar(50),
 IslemTarihi DATETIME,
 IslemYapanKullanici nvarchar(50)
)

create trigger trg_KitapEkleme
on Kitaplar
FOR INSERT
as
begin
 declare @KitapID INT,@IslemTarihi DATETIME,@IslemYapanKullanici nvarchar(50)

 select @KitapID = KitapID from inserted
 set @IslemTarihi = GETDATE()
 set @IslemYapanKullanici = SYSTEM_USER

 insert into LOG_TABLOSU(KitapID,IslemTipi,IslemTarihi,IslemYapanKullanici)
 values (@KitapID,'INSERT',@IslemTarihi,@IslemYapanKullanici)
end

create trigger trg_LogKitapSilme
on Kitaplar
FOR DELETE
as 
begin

 DECLARE @KitapID int, @IslemTarihi DATETIME,@IslemYapanKullanici nvarchar(50)

 select @KitapID = KitapID from deleted
 set @IslemTarihi = GETDATE()
 set @IslemYapanKullanici = SYSTEM_USER

 insert into LOG_TABLOSU (KitapID, IslemTipi, IslemTarihi, IslemYapanKullanici)
 values (@KitapID, 'DELETE',@IslemTarihi,@IslemYapanKullanici)
end


insert into Kitaplar(KitapAdi, Yazar, Yayinevi, BasimYili, StokMiktari)
values ('Yüzüklerin Efendisi - Geri Dönüþ','J.R.R. Tolkien','Ýthaki Yayýnlarý',1954,3)

DELETE FROM OduncAlmalar WHERE KitapID = 5;
DELETE FROM Kitaplar WHERE KitapID = 5;

/* View */

CREATE VIEW vw_OduncAlinanKitaplar
AS
SELECT
  OA.OduncID,
  K.KitapAdi,
  U.UyeAdi,
  OA.OduncAlmaTarihi,
  OA.TeslimTarihi
FROM
  OduncAlmalar OA
  JOIN Kitaplar K ON OA.KitapID = K.KitapID
  JOIN Uyeler U ON OA.UyeID = U.UyeID;


SELECT * FROM vw_OduncAlinanKitaplar;

/* Fonksiyon */

CREATE FUNCTION dbo.fn_UyeOduncSayisi(@UyeID INT)
RETURNS INT
AS
BEGIN
  DECLARE @OduncSayisi INT;
  SELECT @OduncSayisi = COUNT(*) FROM OduncAlmalar WHERE UyeID = @UyeID;
  RETURN @OduncSayisi;
END


SELECT dbo.fn_UyeOduncSayisi(2);

/* Transaction */

BEGIN TRANSACTION
BEGIN TRY
  INSERT INTO OduncAlmalar (KitapID, UyeID, OduncAlmaTarihi, TeslimTarihi)
  VALUES (6, 2, GETDATE(), DATEADD(DAY, 15, GETDATE()));

  COMMIT;
  PRINT 'Transaction baþarýlý ve commit edildi';
END TRY
BEGIN CATCH
  ROLLBACK;
  PRINT 'Transaction baþarýsýz ve rollback yapýldý';
END CATCH;

/* Ýndex */

CREATE NONCLUSTERED INDEX IX_OduncAlmaTarihi 
ON OduncAlmalar (OduncAlmaTarihi);


SET STATISTICS IO ON;
SET STATISTICS TIME ON;


SELECT * FROM OduncAlmalar 
WHERE OduncAlmaTarihi = '2024-08-09';

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;






UPDATE OduncAlmalar
SET OduncAlmaTarihi = DATEADD(DAY, -FLOOR(RAND(CHECKSUM(NEWID())) * 365), GETDATE()),
    TeslimTarihi = DATEADD(DAY, 15, DATEADD(DAY, -FLOOR(RAND(CHECKSUM(NEWID())) * 365), GETDATE()))
WHERE OduncAlmaTarihi > GETDATE();
