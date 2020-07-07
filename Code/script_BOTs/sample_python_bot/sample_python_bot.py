import os
import time
import sys
import requests
import base64

def updateTask(snowUrl, snowUserName, snowPassword, taskSysId, state, workNotes):
    loginData = snowUserName+':'+snowPassword
    encoded = base64.b64encode(loginData)
    url = 'https://'+snowUrl+'.service-now.com/api/now/table/sc_task/'+taskSysId

    payload = """{
                    "state": "%s",
                    "work_notes":"%s"}"""%(state, workNotes)
    headers = {
        'content-type': "application/json",
        'accept': "application/json",
        'authorization': "Basic %s"%(encoded)
        }

    response = requests.request("PUT", url, data=payload, headers=headers)
    
    print(response.text)


if __name__ == "__main__":
    providerType = sys.argv[1]
    sysid = sys.argv[2]
    task =sys.argv[3]
    snowUrl =sys.argv[4]
    snowUserName = sys.argv[5]
    snowPassword = sys.argv[6] 
    time.sleep(60)
    updateTask(snowUrl, snowUserName, snowPassword, sysid,"3","Terraform BOT successfully executed")
