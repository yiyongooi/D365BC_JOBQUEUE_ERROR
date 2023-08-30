page 88030 "DOP Job Queue Error Setup"
{
    Caption = 'Job Queue Error Setup';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "DOP Job Queue Error";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;

                field("Object Type to Run"; Rec."Object Type to Run")
                { }

                field("Object ID to Run"; Rec."Object ID to Run")
                { }

                field("Object Caption to Run"; Rec."Object Caption to Run")
                { }

                field("Email Subject"; Rec."Email Subject")
                { }

                field("Email To"; Rec."Email To")
                {
                    ToolTip = 'Use semicolons to separate multiple recipients.';
                }

                field("Auto Restart"; Rec."Auto Restart")
                { }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(JobQueueEntry)
            {
                ApplicationArea = All;
                Caption = 'Create/View Job Queue Entry';
                Image = JobListSetup;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    Rec_JobQueueEntry: Record "Job Queue Entry";
                    DummyRecId: RecordID;
                begin
                    Rec_JobQueueEntry.Reset();
                    Rec_JobQueueEntry.SetRange("Object Type to Run", Rec_JobQueueEntry."Object Type to Run"::Report);
                    Rec_JobQueueEntry.SetRange("Object ID to Run", Report::"DOP Job Queue Error Email");
                    if Rec_JobQueueEntry.FindFirst() then begin
                        PAGE.Run(PAGE::"Job Queue Entry Card", Rec_JobQueueEntry);
                    end else begin
                        Rec_JobQueueEntry.ScheduleRecurrentJobQueueEntryWithFrequency(
                                        Rec_JobQueueEntry."Object Type to Run"::Report,
                                        Report::"DOP Job Queue Error Email",
                                        DummyRecId, 24 * 60, 080000T);
                        Rec_JobQueueEntry."Earliest Start Date/Time" := CreateDateTime(CalcDate('+1D', Today), 080000T);
                        Rec_JobQueueEntry."Report Output Type" := Rec_JobQueueEntry."Report Output Type"::"None (Processing only)";
                        Rec_JobQueueEntry.Modify();

                        PAGE.Run(PAGE::"Job Queue Entry Card", Rec_JobQueueEntry);
                    end;
                end;
            }
        }
    }
}