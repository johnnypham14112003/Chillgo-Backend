use master;
go

if exists (select name from sys.databases where name = 'ChillgoDB')
begin
	drop database ChillgoDB;
end;
go

create database ChillgoDB;
go

use ChillgoDB;
go

--dotnet ef dbcontext scaffold "Server=(local);database=ChillgoDB;uid=sa;pwd=12345;TrustServerCertificate=True;" Microsoft.EntityFrameworkCore.SqlServer --output-dir Models --force

create table [Account] (
	Id uniqueidentifier default newid() primary key,
	FirebaseUid nvarchar(max) not null,
	Email nvarchar(100) unique not null,
	[Password] nvarchar(max) not null,
	FullName nvarchar(50) not null,
	[Address] nvarchar(max),
	PhoneNumber nvarchar(15),
	CCCD nvarchar(20),
	DateOfBirth datetime,
	Gender nvarchar (20),
	JoinedDate datetime not null default current_timestamp,
	LastUpdated datetime not null default current_timestamp,
	ChillCoin int default 0 not null,
	FcmToken nvarchar(max),
	GoogleId nvarchar(max),
	FacebookId nvarchar(max),

	--TourGuide
	Expertise nvarchar(max),
	[Language] nvarchar(max),
	Rating decimal(2,1) default 0 not null,

	--Partner
	CompanyName nvarchar(150),
	[Role] nvarchar(30) not null default N'Người Dùng',			--1:Admin	|2:Nhân Viên Quản Lý   3:Đối Tác   4:Hướng Dẫn Viên   5:Người Dùng
	[Status] nvarchar(30) not null default N'Chưa Xác Thực'		--Đã Xác Thực   |   Bị Cấm	 	|   Đã Xóa
);
go
create nonclustered index Idx_Account_AccountEmail on [Account](Email);
create nonclustered index Idx_Account_PhoneNumber on [Account](PhoneNumber);
create nonclustered index Idx_Account_CCCD on [Account]([CCCD]);
create nonclustered index Idx_Account_Status on [Account] ([Status]);
go

create table [VerificationRequest](
	Id uniqueidentifier default newid() primary key,
	Title nvarchar(max) not null default N'Không có tiêu đề',
	Content nvarchar(max) not null default N'Trống',
	SenderId uniqueidentifier not null foreign key references [Account](Id),
	StaffVerifyId uniqueidentifier not null foreign key references [Account](Id),
	[SentDate] datetime not null default current_timestamp,
	[HandleDate] datetime not null default current_timestamp,
	[Status] nvarchar(30) not null default N'Chưa Duyệt'		--Đã Duyệt   |   Không Đạt   |   Đã Hủy
);
go

create table [Hobby](
	Id uniqueidentifier default newid() primary key,
	[Name] nvarchar(100) unique,
	[Description] nvarchar(max)
);
go

create table [HobbyCustomer](
	primary key (HobbyId, AccountId),
	HobbyId uniqueidentifier not null foreign key (HobbyId) references [Hobby](Id),
	AccountId uniqueidentifier not null foreign key references [Account](Id)
);
go
create nonclustered index Idx_HobbyCustomer_AccountId on [HobbyCustomer](AccountId);
go

create table [Voucher](
	Id uniqueidentifier default newid() primary key,
	ExchangeCode nvarchar(100),
	[Name] nvarchar(100) not null,
	[Description] nvarchar(max),
	AvailableDate datetime not null default current_timestamp,
	ExpiredDate datetime not null,
	MinimumTransaction money not null default 0,
	DiscountPercent tinyint default 0 not null,		--100%
	[Status] nvarchar(30) not null default N'Khả Dụng'		--Hết Hạn   |   Đã Xóa
);
go
create nonclustered index Idx_Voucher_Status on [Voucher]([Status]);
go

create table [CustomerVoucher](
	primary key (VoucherId, AccountId),
	VoucherId uniqueidentifier not null foreign key references [Voucher](Id),
	AccountId uniqueidentifier not null foreign key references [Account](Id),
	CollectedDate datetime not null,
	[Status] nvarchar(30) not null default N'Đã Nhận'		--Đã Dùng	|	Hết Hạn	|	Đã Xóa
);
go
create nonclustered index Idx_CustomerVoucher_Status on [CustomerVoucher] ([Status]);
create nonclustered index Idx_CustomerVoucher_CustomerId on [CustomerVoucher] (AccountId);
go

create table [Location](
	Id uniqueidentifier default newid() primary key,
	[Name] nvarchar(100) not null,
	[Description] nvarchar(max),
	[Address] nvarchar(max),
	Coordinates nvarchar(100),
	TicketPrice money not null default 0,
	TotalRating decimal(2,1) default 0 not null,
	IsMarketingPaid bit not null default 0,
	PartnerId uniqueidentifier foreign key references [Account](Id),
	LastUpdated datetime not null default current_timestamp,
	[Status] nvarchar(30) not null default N'Khả Dụng'		--Đã Ẩn   |   Đã Xóa
);
go

create nonclustered index Idx_Location_PartnerId on [Location] (PartnerId);
create nonclustered index Idx_Location_Coordinates on [Location] (Coordinates);
create nonclustered index Idx_Location_IsMarketingPaid on [Location] (IsMarketingPaid);
create nonclustered index Idx_Location_Status on [Location] ([Status]);
go

create table [Blog](
	Id uniqueidentifier default newid() primary key,
	Title nvarchar(max) not null,
	[Description] nvarchar(max) not null,
	TotalRating decimal(2,1) default 0 not null,
	PostedDate datetime not null default current_timestamp,
	AccountId uniqueidentifier foreign key references [Account](Id),
	[Status] nvarchar(30) not null default N'Đã Đăng'			--Đã Duyệt   |   Đã Chỉnh Sửa   |   Đã Bị Gỡ
);
go
create nonclustered index Idx_Blog_PostedDate on [Blog] (PostedDate);
create nonclustered index Idx_Blog_AccountId on [Blog] (AccountId);
create nonclustered index Idx_Blog_Status on [Blog] ([Status]);
go

create table [Comment](
	Id uniqueidentifier default newid() primary key,
	Content nvarchar(max) not null,
	SentTime datetime not null default current_timestamp,
	Rating decimal(2,1) default 0 not null,
	SenderId uniqueidentifier not null foreign key references [Account](Id),
	[Type] tinyint not null default 1,						--1:Location   |   2:Person   |   3:Blog
	[Status] nvarchar(30) not null default N'Đã Gửi',		--Đã Sửa   |   Đã Bị Ẩn   |   Đã Xóa

	LocationId uniqueidentifier foreign key references [Location](Id),
	PersonId uniqueidentifier foreign key references [Account](Id),
	BlogId uniqueidentifier foreign key references [Blog](Id),
	constraint CHK_Comment_OnlyOneEachType check (
		(LocationId is not null and PersonId is null and BlogId is null)--Location
			or 
		(LocationId is null and PersonId is not null and BlogId is null)--Person
			or 
		(LocationId is null and PersonId is null and BlogId is not null)--Blog
    )
);
go
create nonclustered index Idx_Comment_LocationId on [Comment] (LocationId);
create nonclustered index Idx_Comment_PersonId on [Comment] (PersonId);
create nonclustered index Idx_Comment_BlogId on [Comment] (BlogId);
create nonclustered index Idx_Comment_Type on [Comment] ([Type]);
create nonclustered index Idx_Comment_Status on [Comment] ([Status]);
go

create table [ChillCoinTask](
	Id uniqueidentifier default newid() primary key,
	Title nvarchar(max) not null,
	[Description] nvarchar(max) not null,
	RewardCoin int not null default 1,
	[Status] nvarchar(30) not null default N'Khả Dụng'		--Không Khả Dụng   |   Đã Xóa
);
go
create nonclustered index Idx_ChillCoinTask_Status on [ChillCoinTask] ([Status]);
go

create table [CustomerChillCoinTask](
	primary key(AccountId, ChillCoinTaskId),
	ChillCoinTaskId uniqueidentifier not null foreign key references [ChillCoinTask](Id),
	AccountId uniqueidentifier not null foreign key references [Account](Id),
	[Status] nvarchar(30) not null default N'Đã Làm Mới'		--Đã Hủy   |   Đã Hoàn Thành
);
go
create nonclustered index Idx_CustomerChillCoinTask_Status on [CustomerChillCoinTask] ([Status]);
go

create table [Hotel](
	Id uniqueidentifier default newid() primary key,
	[Name] nvarchar(100) not null,
	[Description] nvarchar(max),
	Utilities nvarchar(max),
	[Address] nvarchar(max),
	TotalFloor tinyint not null default 0,
	[Hotline] nvarchar(15) not null default N'Trống',
	TotalRating decimal(2,1) default 0 not null,
	IsMarketingPaid bit not null default 0,
	PriceRange nvarchar(200) default '0-0',
	[Status] nvarchar(30) not null default N'Còn Phòng'			--Hết Phòng   |   Tạm Ngưng   |   Đã Đóng Cửa
);
go
create nonclustered index Idx_Hotel_Hotline on [Hotel] ([Hotline]);
create nonclustered index Idx_Hotel_Status on [Hotel] ([Status]);
go

create table [HotelRoom](
	Id uniqueidentifier default newid() primary key,
	HotelId uniqueidentifier not null foreign key references [Hotel](Id),
	[RoomNo] nvarchar(30),
	[Floor] nvarchar(30),
	[Type] nvarchar(100) not null default N'Giường Đơn',			--Giường Đôi  |  Ban Công   |   ...
	Utilities nvarchar(max),
	PricePerNight money not null default 0,
	Capacity tinyint not null default 0,
	[Status] nvarchar(30) not null default N'Sẵn Sàng'			--Bận   |  Chờ Dọn   |   Tạm Ngưng   |   Đặt Trước
);
go
create nonclustered index Idx_HotelRoom_HotelId on [HotelRoom] (HotelId);
create nonclustered index Idx_HotelRoom_Type on [HotelRoom] ([Type]);
create nonclustered index Idx_HotelRoom_Status on [HotelRoom] ([Status]);
go

create table [Transport](
	Id uniqueidentifier default newid() primary key,
	[Type] nvarchar(100) not null default N'Xe Ô Tô',			--Xe Buýt
	[Name] nvarchar(100) not null,
	[Address] nvarchar(max),
	LuggageSlot tinyint not null default 1,
	SitSlot tinyint not null default 1,
	[Provider] nvarchar(100) not null,
	TotalRating decimal(2,1) default 0 not null,
	PricePerDay money not null default 0,
	[Status] nvarchar(30) not null default N'Sẵn Sàng'			--Đã Bị Thuê   |   Tạm Ngưng
);
go
create nonclustered index Idx_Transport_Type on [Transport] ([Type]);
create nonclustered index Idx_Transport_Status on [Transport] ([Status]);
go

create table [FavoritedLocation](
	primary key(AccountId, LocationId),
	AccountId uniqueidentifier not null foreign key references [Account](Id),
	LocationId uniqueidentifier not null foreign key references [Location](Id)
);
go
create nonclustered index Idx_FavoritedLocation_AccountId on [FavoritedLocation] (AccountId);
go

create table [FavoritedPerson](
	primary key(AccountId, PersonId),
	AccountId uniqueidentifier not null foreign key references [Account](Id),
	PersonId uniqueidentifier not null foreign key references [Account](Id),
	IsTourGuide bit default 0 not null
);
go
create nonclustered index Idx_FavoritedPerson_AccountId on [FavoritedPerson] (AccountId);
go

create table [FavoritedHotel](
	primary key(AccountId, HotelId),
	AccountId uniqueidentifier not null foreign key references [Account](Id),
	HotelId uniqueidentifier not null foreign key references [Hotel](Id),
);
go
create nonclustered index Idx_FavoritedHotel_AccountId on [FavoritedHotel] (AccountId);
go

create table [FavoritedTransport](
	primary key(AccountId, TransportId),
	AccountId uniqueidentifier not null foreign key references [Account](Id),
	TransportId uniqueidentifier not null foreign key references [Transport](Id)
);
go
create nonclustered index Idx_FavoritedTransport_AccountId on [FavoritedTransport] (AccountId);
go

create table [Booking](
	Id uniqueidentifier default newid() primary key,
	BookedDate datetime not null default current_timestamp,
	PayMethod nvarchar(30) not null default N'Tiền Mặt',
	ChillCoinApplied int not null default 0,
	TotalPrice money not null default 0,						--Total = (all subtotal of Detail) - [(all subtotal of Detail)* Voucher] - ChillCoin*10
	Note nvarchar(max) not null default N'Trống!',
	[Status] nvarchar(30) not null default N'Giỏ Hàng',			--Chờ Xác Nhận   |   Đã Xác Nhận   |   Chờ Thanh Toán   |   Đã Hủy   |   Đã Thanh Toán   |   Chờ Hoàn Tiền   |   Đã Hoàn Tiền   |   Hoàn Thành   |   Đã Xóa

	AccountId uniqueidentifier not null foreign key references [Account](Id),
	VoucherId uniqueidentifier foreign key references [Voucher](Id)
);
go
create nonclustered index Idx_Booking_Status on [Booking] ([Status]);
go

create table [BookingDetail](
	Id uniqueidentifier default newid() primary key,
	BookingId uniqueidentifier not null foreign key references [Booking](Id),
	NumberOfPeople smallint not null default 0,
	Subtotal money not null default 0,										--Subtotal = (Detail Price) + [(Detail Price) * (Voucher Percent)]
	StartDate datetime,
	EndDate datetime,
	[Status] nvarchar(30) not null default N'Giỏ Hàng',						--Chờ Xác Nhận   |   Đã Xác Nhận   |   Chờ Thanh Toán   |   Đã Hủy   |   Đã Thanh Toán   |   Chờ Hoàn Tiền   |   Đã Hoàn Tiền   |   Hoàn Thành   |   Đã Xóa
	
	[RoomType] nvarchar(100),
	QuantityRoom smallint not null default 0,
	
	TourGuideId uniqueidentifier foreign key references [Account](Id),
	LocationId uniqueidentifier foreign key references [Location](Id),
	HotelId uniqueidentifier foreign key references [Hotel](Id),
	TransportId uniqueidentifier foreign key references [Transport](Id),
	RoomId uniqueidentifier foreign key references [HotelRoom](Id),
	VoucherId uniqueidentifier foreign key references [Voucher](Id),

	constraint CHK_BookingDetail_OnlyOneEachType check (
		(TourGuideId is not null and LocationId is null and HotelId is null and TransportId is null)--TourGuide
			or
		(TourGuideId is null and LocationId is not null and HotelId is null and TransportId is null)--Location
			or
		(TourGuideId is null and LocationId is null and HotelId is not null and TransportId is null)--Hotel
			or
		(TourGuideId is null and LocationId is null and HotelId is null and TransportId is not null)--Transport
    )
);
go
create nonclustered index Idx_BookingDetail_TourGuideId on [BookingDetail] (TourGuideId);
create nonclustered index Idx_BookingDetail_LocationId on [BookingDetail] (LocationId);
create nonclustered index Idx_BookingDetail_HotelId on [BookingDetail] (HotelId);
create nonclustered index Idx_BookingDetail_TransportId on [BookingDetail] (TransportId);
create nonclustered index Idx_BookingDetail_Status on [BookingDetail] ([Status]);
go

create table [Package](
	Id uniqueidentifier default newid() primary key,
	Code nvarchar(20) not null unique,
	[Name] nvarchar(50) not null,
	[Description] nvarchar(max),
	Price money not null default 0,
	Duration smallint not null default 0,						--month
	[Status] nvarchar(30) not null default N'Đang Bán'			--Ngừng Hỗ Trợ
);
go
create nonclustered index Idx_Package_Status on [Package] ([Status]);
go

create table [PackageTransaction](
	Id uniqueidentifier default newid() primary key,
	AccountId uniqueidentifier not null foreign key references [Account](Id),
	PackageId uniqueidentifier not null foreign key references [Package](Id),
	ChillCoinApplied int not null default 0,
	PaidAt datetime not null default current_timestamp,
	PayMethod nvarchar(30) not null default N'Tiền Mặt',
	TotalPrice money not null default 0,						--included chillcoin and voucher
	StartDate datetime not null default current_timestamp,
	EndDate datetime,
	VoucherCodeList nvarchar(max),
	[Status] nvarchar(30) not null default N'Đã Mua'			--Chờ Hoàn Tiền   |   Đã Hoàn Tiền
);
go
create nonclustered index Idx_PackageTransaction_AccountId on [PackageTransaction] (AccountId);
create nonclustered index Idx_PackageTransaction_PackageId on [PackageTransaction] (PackageId);
create nonclustered index Idx_PackageTransaction_Status on [PackageTransaction] ([Status]);
go

create table [SalaryTransaction](
	Id uniqueidentifier default newid() primary key,
	AccountId uniqueidentifier not null foreign key references [Account](Id),
	PaidAt datetime not null default current_timestamp,
	BaseSalary money not null default 0,
	Bonus money not null default 0,
	PayMethod nvarchar(30) not null default N'Tiền Mặt',
	TotalPaid money not null default 0,
	Content nvarchar(max) not null,
	[Status] nvarchar(30) not null default N'Đã Chuyển Trả'			--Chưa Nhận Được   |   Đã Thanh Toán   |   Đã Xóa
);
go
create nonclustered index Idx_SalaryTransaction_AccountId on [SalaryTransaction] (AccountId);
create nonclustered index Idx_SalaryTransaction_PaidAt on [SalaryTransaction] (PaidAt);
create nonclustered index Idx_SalaryTransaction_Status on [SalaryTransaction] ([Status]);
go

create table [BotAI](
	Id uniqueidentifier default newid() primary key,
	[Name] nvarchar(100) not null,
	Capabilities nvarchar(max),
	[Provider] nvarchar(100) not null,
	ClientKey nvarchar(max),
	APIEndpoint nvarchar(max),
	APIToken nvarchar(max),										--For Auth Neccessary
	TrainingFileURL nvarchar(max),
	CreatedDate datetime not null default current_timestamp,
	[Status] nvarchar(30) not null default N'Khả Dụng'			--Tạm Ngưng   |   Không Khả Dụng
);
go
create nonclustered index Idx_BotAI_Status on [BotAI] ([Status]);
go

create table [Conversation](
	Id uniqueidentifier default newid() primary key,
	IsHuman bit not null default 1,

	FirstName nvarchar(50),
	FirstAccountId uniqueidentifier foreign key references [Account](Id),

	SecondName nvarchar(50),
	SecondAccountId uniqueidentifier foreign key references [Account](Id),

	AIBotId uniqueidentifier foreign key references [BotAI](Id),

	LastUpdated datetime not null default current_timestamp,
	[Status] nvarchar(30) not null default N'Chờ Xác Nhận'
);
go
create nonclustered index Idx_Conversation_FirstAccountId on [Conversation] (FirstAccountId);
create nonclustered index Idx_Conversation_SecondAccountId on [Conversation] (SecondAccountId);
create nonclustered index Idx_Conversation_AIBotId on [Conversation] (AIBotId);
create nonclustered index Idx_Conversation_Status on [Conversation] ([Status]);
go

create table [Message](
	Id uniqueidentifier default newid() primary key,
	ConversationId uniqueidentifier not null foreign key references [Conversation](Id),
	Content nvarchar(max) not null,
	SentTime datetime not null default current_timestamp,
	[Status] nvarchar(30) not null default N'Chưa Gửi',					--Đã Gửi   |   Gửi Lỗi   |   Đã Thu Hồi

	SenderId uniqueidentifier foreign key references [Account](Id),
	BotReplyId uniqueidentifier foreign key references [BotAI](Id),

	constraint CHK_Message_HumanOrBot check (
		(SenderId is not null and BotReplyId is null)--Sender
			or
		(SenderId is null and BotReplyId is not null)--Bot
	)
);
go
create nonclustered index Idx_Message_SenderId on [Message] (SenderId);
create nonclustered index Idx_Message_BotReplyId on [Message] (BotReplyId);
create nonclustered index Idx_Message_Status on [Message] ([Status]);
go

create table [Plan](
	Id uniqueidentifier default newid() primary key,
	AccountId uniqueidentifier not null foreign key references [Account](Id),
	[Name] nvarchar(100) not null,
	StartDate datetime,
	EndDate datetime,
	TotalCost money not null default 0,
	CreatedDate datetime not null default current_timestamp,
	[Status] nvarchar(30) not null default N'Đã Tạo'			--Đã hoàn thành   |   Đã Xóa
);
go
create nonclustered index Idx_Plan_AccountId on [Plan] (AccountId);
create nonclustered index Idx_Plan_Status on [Plan] ([Status]);
go

create table [Schedule](
	Id uniqueidentifier default newid() primary key,
	PlanId uniqueidentifier not null foreign key references [Plan](Id),
	[Content] nvarchar(max) not null,
	EstimatedCost money not null default 0,
	[TimeStamp] datetime not null default current_timestamp,

	LocationId uniqueidentifier foreign key references [Location](Id),
	HotelId uniqueidentifier foreign key references [Hotel](Id),
	TransportId uniqueidentifier foreign key references [Transport](Id),

	constraint CHK_Schedule_NoneOrOnlyOne check (
		(LocationId is null and HotelId is null and TransportId is null)--none
			or
		(LocationId is not null and HotelId is null and TransportId is null)--Location
			or 
		(LocationId is null and HotelId is not null and TransportId is null)--Hotel
			or 
		(LocationId is null and HotelId is null and TransportId is not null)--Transport
	)
);
go
create nonclustered index Idx_Schedule_PlanId on [Schedule] (PlanId);
go

create table [Image](
	Id uniqueidentifier default newid() primary key,
	UrlPath nvarchar(max),
	IsAvatar bit not null default 0,
	[Type] tinyint not null default 1,							--1:Account   |   2:Verification   |   3:Location   |   4:Hotel   |   5:Vehicle   |  6:Blog   |   7:Voucher
	[Status] nvarchar(30) not null default N'Đã Tải Lên',		--Đã Xóa

	AccountId uniqueidentifier foreign key references [Account](Id),
	CertificateId uniqueidentifier foreign key references [VerificationRequest](Id),
	LocationId uniqueidentifier foreign key references [Location](Id),
	HotelId uniqueidentifier foreign key references [Hotel](Id),
	TransportId uniqueidentifier foreign key references [Transport](Id),
	BlogId uniqueidentifier foreign key references [Blog](Id),
	VoucherId uniqueidentifier foreign key references [Voucher](Id),

	constraint CHK_Image_OnlyOneEachType check (
		(AccountId is not null and CertificateId is null and LocationId is null and HotelId is null and TransportId is null and BlogId is null and VoucherId is null)--Account
			or 
		(AccountId is null and CertificateId is not null and LocationId is null and HotelId is null and TransportId is null and BlogId is null and VoucherId is null)--Certificate
			or 
		(AccountId is null and CertificateId is null and LocationId is not null and HotelId is null and TransportId is null and BlogId is null and VoucherId is null)--Location
			or 
		(AccountId is null and CertificateId is null and LocationId is null and HotelId is not null and TransportId is null and BlogId is null and VoucherId is null)--Hotel
			or 
		(AccountId is null and CertificateId is null and LocationId is null and HotelId is null and TransportId is not null and BlogId is null and VoucherId is null)--Transport
			or 
		(AccountId is null and CertificateId is null and LocationId is null and HotelId is null and TransportId is null and BlogId is not null and VoucherId is null)--Blog
			or
		(AccountId is null and CertificateId is null and LocationId is null and HotelId is null and TransportId is null and BlogId is null and VoucherId is not null)--Voucher
    )
);
go
create nonclustered index Idx_Image_AccountId on [Image] (AccountId);
create nonclustered index Idx_Image_LocationId on [Image] (LocationId);
create nonclustered index Idx_Image_HotelId on [Image] (HotelId);
create nonclustered index Idx_Image_TransportId on [Image] (TransportId);
create nonclustered index Idx_Image_BlogId on [Image] (BlogId);
create nonclustered index Idx_Image_VoucherId on [Image] (VoucherId);
go

use master;