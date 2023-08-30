report 88030 "DOP Job Queue Error Email"
{
    Caption = 'Job Queue Error Email';
    ProcessingOnly = true;
    UseRequestPage = false;

    dataset
    {
        dataitem("DOP Job Queue Error"; "DOP Job Queue Error")
        {
            trigger OnAfterGetRecord()
            var
                Rec_JobQueueEntry: Record "Job Queue Entry";

                MailList: List of [Text];
                MsgBody: Text[2048];
                CU_EmailMessage: Codeunit "Email Message";
                CU_Email: Codeunit Email;
                Rec_ErrorMessage: Record "Error Message";
            begin
                Rec_JobQueueEntry.Reset();
                Rec_JobQueueEntry.SetRange("Object Type to Run", "DOP Job Queue Error"."Object Type to Run");
                Rec_JobQueueEntry.SetRange("Object ID to Run", "DOP Job Queue Error"."Object ID to Run");
                if Rec_JobQueueEntry.FindSet() then begin

                    if Rec_JobQueueEntry.Status <> Rec_JobQueueEntry.Status::Error then
                        CurrReport.Skip();

                    if StrPos("DOP Job Queue Error"."Email To", ';') > 0 then begin
                        MailList := "DOP Job Queue Error"."Email To".Split(';');
                    end else begin
                        MailList.Add("DOP Job Queue Error"."Email To");
                    end;

                    Rec_ErrorMessage.Reset();
                    Rec_ErrorMessage.SetRange("Register ID", Rec_JobQueueEntry."Error Message Register Id");
                    Rec_ErrorMessage.FindSet();

                    Rec_JobQueueEntry.CalcFields("Object Caption to Run");

                    MsgBody += '<p><strong>Object Type:&nbsp;</strong>';
                    MsgBody += Format(Rec_JobQueueEntry."Object Type to Run");
                    MsgBody += '<br><strong>Object ID:&nbsp;</strong>';
                    MsgBody += Format(Rec_JobQueueEntry."Object ID to Run");
                    MsgBody += '<br><strong>Object Caption:&nbsp;</strong>';
                    MsgBody += Format(Rec_JobQueueEntry."Object Caption to Run");
                    MsgBody += '</p>';
                    MsgBody += '<p><strong>Error DateTime:&nbsp;</strong>';
                    MsgBody += Format(Rec_ErrorMessage."Created On");
                    MsgBody += '<br>';
                    MsgBody += '<strong>Error Message</strong></p>';
                    MsgBody += '<blockquote>';
                    MsgBody += Rec_JobQueueEntry."Error Message";
                    MsgBody += '</blockquote>';
                    MsgBody += '<br>';
                    MsgBody += '<p style="text-align: center;">This is a system-generated email. Please do not reply to this message.</p>';

                    CU_EmailMessage.Create(MailList, "DOP Job Queue Error"."Email Subject", MsgBody, true);
                    if not CU_Email.Send(CU_EmailMessage) then
                        Error(FailToSendEmail);

                    if "DOP Job Queue Error"."Auto Restart" then
                        Rec_JobQueueEntry.Restart();
                end else begin
                    if StrPos("DOP Job Queue Error"."Email To", ';') > 0 then begin
                        MailList := "DOP Job Queue Error"."Email To".Split(';');
                    end else begin
                        MailList.Add("DOP Job Queue Error"."Email To");
                    end;

                    "DOP Job Queue Error".CalcFields("Object Caption to Run");

                    MsgBody += '<p><strong>Object Type:&nbsp;</strong>';
                    MsgBody += Format("DOP Job Queue Error"."Object Type to Run");
                    MsgBody += '<br><strong>Object ID:&nbsp;</strong>';
                    MsgBody += Format("DOP Job Queue Error"."Object ID to Run");
                    MsgBody += '<br><strong>Object Caption:&nbsp;</strong>';
                    MsgBody += Format("DOP Job Queue Error"."Object Caption to Run");
                    MsgBody += '</p>';
                    MsgBody += '<p><strong>Error Message</strong></p>';
                    MsgBody += '<blockquote>';
                    MsgBody += 'Object not found in Job Queue Entries.';
                    MsgBody += '</blockquote>';
                    MsgBody += '<br>';
                    MsgBody += '<p style="text-align: center;">This is a system-generated email. Please do not reply to this message.</p>';

                    CU_EmailMessage.Create(MailList, "DOP Job Queue Error"."Email Subject", MsgBody, true);
                    if not CU_Email.Send(CU_EmailMessage) then
                        Error(FailToSendEmail);
                end;
            end;

            trigger OnPreDataItem()
            begin
                SetFilter("Email To", '<>%1', '');
                SetFilter("Object ID to Run", '>%1', 0);
            end;
        }
    }

    var
        FailToSendEmail: Label 'Failed to send out email, check if Email Account is configured correctly.';
}