table 88030 "DOP Job Queue Error"
{
    Caption = 'Job Queue Error';

    fields
    {
        field(10; "Object ID to Run"; Integer)
        {
            Caption = 'Object ID to Run';
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = FIELD("Object Type to Run"));

            trigger OnLookup()
            var
                NewObjectID: Integer;
            begin
                if LookupObjectID(NewObjectID) then
                    Validate("Object ID to Run", NewObjectID);
            end;

            trigger OnValidate()
            var
                Rec_JQE: Record "Job Queue Entry";
                AllObj: Record AllObj;
            begin
                if "Object ID to Run" = 0 then
                    exit;
                if not AllObj.Get("Object Type to Run", "Object ID to Run") then
                    Error(ObjNotFoundErr, "Object ID to Run");
                if "Object Type to Run" <> "Object Type to Run"::Report then
                    exit;

                Rec_JQE.Reset();
                Rec_JQE.SetRange("Object Type to Run", Rec."Object Type to Run");
                Rec_JQE.SetRange("Object ID to Run", Rec."Object ID to Run");
                if not Rec_JQE.FindSet() then begin
                    if not Dialog.Confirm(JQENotFoundErr) then begin
                        Error(JQECreateFirstErr);
                    end;
                end;
            end;
        }

        field(20; "Object Caption to Run"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = FIELD("Object Type to Run"),
                                                                           "Object ID" = FIELD("Object ID to Run")));
            Caption = 'Object Caption to Run';
            Editable = false;
            FieldClass = FlowField;
        }

        field(30; "Object Type to Run"; Option)
        {
            Caption = 'Object Type to Run';
            InitValue = "Report";
            OptionCaption = ',,,Report,,Codeunit';
            OptionMembers = ,,,"Report",,"Codeunit";

            trigger OnValidate()
            begin
                if "Object Type to Run" <> xRec."Object Type to Run" then
                    Validate("Object ID to Run", 0);
            end;
        }

        field(40; "Email Subject"; Text[50])
        {
            Caption = 'Email Subject';
        }

        field(50; "Email To"; Text[300])
        {
            Caption = 'Email To';

            trigger OnValidate()
            var
                CU_MailMgmt: Codeunit "Mail Management";
            begin
                CU_MailMgmt.CheckValidEmailAddresses(Rec."Email To");
            end;
        }

        field(60; "Auto Restart"; Boolean)
        {
            Caption = 'Auto Restart';
        }
    }

    keys
    {
        key(Key1; "Object ID to Run")
        {
            Clustered = true;
        }
    }

    var
        JQENotFoundErr: Label 'Object is not found in Job Queue Entries, do you want to continue?';
        JQECreateFirstErr: Label 'Action Cancelled';
        ObjNotFoundErr: Label 'There is no Object with ID %1.', Comment = '%1=Object Id.';

    procedure LookupObjectID(var NewObjectID: Integer): Boolean
    var
        AllObjWithCaption: Record AllObjWithCaption;
        Objects: Page Objects;
    begin
        if AllObjWithCaption.Get("Object Type to Run", "Object ID to Run") then;
        AllObjWithCaption.FilterGroup(2);
        AllObjWithCaption.SetRange("Object Type", "Object Type to Run");
        AllObjWithCaption.FilterGroup(0);
        Objects.SetRecord(AllObjWithCaption);
        Objects.SetTableView(AllObjWithCaption);
        Objects.LookupMode := true;
        if Objects.RunModal() = ACTION::LookupOK then begin
            Objects.GetRecord(AllObjWithCaption);
            NewObjectID := AllObjWithCaption."Object ID";
            exit(true);
        end;
        exit(false);
    end;
}