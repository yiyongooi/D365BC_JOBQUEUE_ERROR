pageextension 88030 _JobQueueEntries extends "Job Queue Entries"
{
    actions
    {
        addfirst(processing)
        {
            action("DOP Job Queue Error Setup")
            {
                ApplicationArea = All;
                Caption = 'Job Queue Error Setup';
                Image = ErrorLog;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "DOP Job Queue Error Setup";
            }
        }
    }
}

