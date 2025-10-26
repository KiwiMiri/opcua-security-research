/**
 * open62541 기반 OPC UA 서버
 */

#include <signal.h>
#include <stdlib.h>
#include "open62541.h"

UA_Boolean running = true;

static void stopHandler(int sig) {
    running = false;
}

int main(void) {
    signal(SIGINT, stopHandler);
    signal(SIGTERM, stopHandler);

    UA_Server *server = UA_Server_new();
    UA_ServerConfig_setDefault(UA_Server_getConfig(server));

    /* 네임스페이스 추가 */
    UA_UInt16 nsIdx;
    UA_String name = UA_STRING("http://open62541-research.org");
    UA_Server_addNamespace(server, name, &nsIdx);

    /* 변수 노드 추가 */
    UA_VariableAttributes attr = UA_VariableAttributes_default;
    UA_Float temperature = 25.0;
    UA_Variant_setScalar(&attr.value, &temperature, &UA_TYPES[UA_TYPES_FLOAT]);
    attr.description = UA_LOCALIZEDTEXT("en-US","Temperature");
    attr.displayName = UA_LOCALIZEDTEXT("en-US","Temperature");

    UA_NodeId temperatureId = UA_NODEID_STRING(nsIdx, "Temperature");
    UA_QualifiedName temperatureName = UA_QUALIFIEDNAME(nsIdx, "Temperature");
    UA_NodeId parentNodeId = UA_NODEID_NUMERIC(0, UA_NS0ID_OBJECTSFOLDER);
    UA_NodeId parentReferenceNodeId = UA_NODEID_NUMERIC(0, UA_NS0ID_ORGANIZES);
    UA_Server_addVariableNode(server, temperatureId, parentNodeId,
                               parentReferenceNodeId, temperatureName,
                               UA_NODEID_NULL, attr, NULL, NULL);

    /* 서버 시작 */
    UA_StatusCode retval = UA_Server_run(server, &running);

    UA_Server_delete(server);
    return retval == UA_STATUSCODE_GOOD ? EXIT_SUCCESS : EXIT_FAILURE;
}
