--Insert Messages to Process Inbox and Notifications
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO dbo.Notification
	(userid, creationTimeStamp, notificationtypeID,notificationText)
	SELECT DISTINCT ua.userID, GETDATE(), 17 ,'Upcoming review for : '+r.firstname+' '+r.lastname+' '+ r.Review_Date
	FROM dbo.useraccount ua
	CROSS JOIN #Review r
	where ua.disable <> 1 and ua.personID = r.staffPersonID  and (ua.expiresdate IS NULL OR ua.expiresdate + '23:59:59' >= GETDATE())  and ua.homepage IS NULL


END

BEGIN 
SET @RecordCount =(SELECT COUNT(PersonID)PersonID from #Review)

IF @RecordCount >0


	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	

INSERT INTO message 
(senderID, subject, createdDate, createdTime,createdTimeStamp, type)
SELECT 1, 'Upcoming review for : '+r.firstname+' '+r.lastname Name,GETDATE() CreatedDate, GETDATE() CreatedTime, GETDATE(), 'Normal'
FROM #Review r

INSERT INTO MessageRecipient
(messageID, personID, studentID, recipientType)
SELECT m.messageid, r.staffpersonID,r.personID,'P'
FROM message m
JOIN #Review r ON r.firstname+' '+r.lastname =Substring(m.subject,23,50)
where m.subject LIKE 'Upcoming review for%'
order by staffpersonid



INSERT INTO dbo.ProcessMessage
	(personid, name,Process, postedTimestamp, type) /* actionRequired, url?, type='workflow'?, contextID? */
	--SELECT DISTINCT  49574 PersonID,'ELL Record created for: '+i.firstname+' '+i.lastname,'Message'/*anything better?*/,getdate()
	SELECT DISTINCT mr.personid, 'Upcoming review for : '+r.firstname+' '+r.lastname Name,'Message' Process, GETDATE(), 'IC Message'--,mr.messageRecipientID
	FROM dbo.useraccount ua
	JOIN #Review r ON r.staffPersonID = ua.personID
	JOIN messagerecipient mr ON mr.personid = r.staffpersonid
	JOIN message m ON m.messageID = mr.messageID
	where ua.disable <> 1 and ua.personID = r.staffPersonID  and (ua.expiresdate IS NULL OR ua.expiresdate + '23:59:59' >= GETDATE())  and ua.homepage IS NULL and m.subject LIKE 'Upcoming review for%'
	order by mr.personID
END