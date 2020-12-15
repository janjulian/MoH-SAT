//Generated by wsdl2apex

public class AsyncEmpi {
    public class HCIM_IN_FindCandidatesResponseFuture extends System.WebServiceCalloutFuture {
        public Empi.HCIM_IN_FindCandidatesResponse getValue() {
            Empi.HCIM_IN_FindCandidatesResponse response = (Empi.HCIM_IN_FindCandidatesResponse)System.WebServiceCallout.endInvoke(this);
            return response;
        }
    }
    public class HCIM_IN_GetRelatedIdentifiersResponseFuture extends System.WebServiceCalloutFuture {
        public Empi.HCIM_IN_GetRelatedIdentifiersResponse getValue() {
            Empi.HCIM_IN_GetRelatedIdentifiersResponse response = (Empi.HCIM_IN_GetRelatedIdentifiersResponse)System.WebServiceCallout.endInvoke(this);
            return response;
        }
    }
    public class HCIM_IN_GetDemographicsResponseFuture extends System.WebServiceCalloutFuture {
        public Empi.HCIM_IN_GetDemographicsResponse getValue() {
            Empi.HCIM_IN_GetDemographicsResponse response = (Empi.HCIM_IN_GetDemographicsResponse)System.WebServiceCallout.endInvoke(this);
            return response;
        }
    }
    public class AsyncQUPA_AR101102_Port {
        public String endpoint_x = 'http://localhost/hcim/QUPA_AR101102.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'urn:hl7-org:v3', 'Empi'};
        public AsyncEmpi.HCIM_IN_FindCandidatesResponseFuture beginHCIM_IN_FindCandidates(System.Continuation continuation,Empi.II id,Empi.TS creationTime,Empi.CS versionCode,Empi.II interactionId,Empi.CS processingCode,Empi.CS processingModeCode,Empi.CS acceptAckCode,Empi.MCCI_MT000100_Receiver receiver,Empi.MCCI_MT000100_Sender sender,Empi.HCIM_IN_FindCandidates_QUQI_MT020001_ControlActProcess controlActProcess) {
            Empi.HCIM_IN_FindCandidates request_x = new Empi.HCIM_IN_FindCandidates();
            request_x.id = id;
            request_x.creationTime = creationTime;
            request_x.versionCode = versionCode;
            request_x.interactionId = interactionId;
            request_x.processingCode = processingCode;
            request_x.processingModeCode = processingModeCode;
            request_x.acceptAckCode = acceptAckCode;
            request_x.receiver = receiver;
            request_x.sender = sender;
            request_x.controlActProcess = controlActProcess;
            return (AsyncEmpi.HCIM_IN_FindCandidatesResponseFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncEmpi.HCIM_IN_FindCandidatesResponseFuture.class,
              continuation,
              new String[]{endpoint_x,
              'urn:hl7-org:v3/QUPA_IN101103',
              'urn:hl7-org:v3',
              'HCIM_IN_FindCandidates',
              'urn:hl7-org:v3',
              'HCIM_IN_FindCandidatesResponse',
              'Empi.HCIM_IN_FindCandidatesResponse'}
            );
        }
        public AsyncEmpi.HCIM_IN_GetRelatedIdentifiersResponseFuture beginHCIM_IN_GetRelatedIdentifiers(System.Continuation continuation,Empi.II id,Empi.TS creationTime,Empi.CS versionCode,Empi.II interactionId,Empi.CS processingCode,Empi.CS processingModeCode,Empi.CS acceptAckCode,Empi.MCCI_MT000100_Receiver receiver,Empi.MCCI_MT000100_Sender sender,Empi.HCIM_IN_GetRelatedIdentifiers_QUQI_MT020001_ControlActProcess controlActProcess) {
            Empi.HCIM_IN_GetRelatedIdentifiers request_x = new Empi.HCIM_IN_GetRelatedIdentifiers();
            request_x.id = id;
            request_x.creationTime = creationTime;
            request_x.versionCode = versionCode;
            request_x.interactionId = interactionId;
            request_x.processingCode = processingCode;
            request_x.processingModeCode = processingModeCode;
            request_x.acceptAckCode = acceptAckCode;
            request_x.receiver = receiver;
            request_x.sender = sender;
            request_x.controlActProcess = controlActProcess;
            return (AsyncEmpi.HCIM_IN_GetRelatedIdentifiersResponseFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncEmpi.HCIM_IN_GetRelatedIdentifiersResponseFuture.class,
              continuation,
              new String[]{endpoint_x,
              'urn:hl7-org:v3/QUPA_IN101105',
              'urn:hl7-org:v3',
              'HCIM_IN_GetRelatedIdentifiers',
              'urn:hl7-org:v3',
              'HCIM_IN_GetRelatedIdentifiersResponse',
              'Empi.HCIM_IN_GetRelatedIdentifiersResponse'}
            );
        }
        public AsyncEmpi.HCIM_IN_GetDemographicsResponseFuture beginHCIM_IN_GetDemographics(System.Continuation continuation,Empi.II id,Empi.TS creationTime,Empi.CS versionCode,Empi.II interactionId,Empi.CS processingCode,Empi.CS processingModeCode,Empi.CS acceptAckCode,Empi.MCCI_MT000100_Receiver receiver,Empi.MCCI_MT000100_Sender sender,Empi.HCIM_IN_GetDemographics_QUQI_MT020001_ControlActProcess controlActProcess) {
            Empi.HCIM_IN_GetDemographics request_x = new Empi.HCIM_IN_GetDemographics();
            request_x.id = id;
            request_x.creationTime = creationTime;
            request_x.versionCode = versionCode;
            request_x.interactionId = interactionId;
            request_x.processingCode = processingCode;
            request_x.processingModeCode = processingModeCode;
            request_x.acceptAckCode = acceptAckCode;
            request_x.receiver = receiver;
            request_x.sender = sender;
            request_x.controlActProcess = controlActProcess;
            return (AsyncEmpi.HCIM_IN_GetDemographicsResponseFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncEmpi.HCIM_IN_GetDemographicsResponseFuture.class,
              continuation,
              new String[]{endpoint_x,
              'urn:hl7-org:v3/QUPA_IN101101',
              'urn:hl7-org:v3',
              'HCIM_IN_GetDemographics',
              'urn:hl7-org:v3',
              'HCIM_IN_GetDemographicsResponse',
              'Empi.HCIM_IN_GetDemographicsResponse'}
            );
        }
    }
}