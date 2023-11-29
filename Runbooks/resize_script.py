import boto3

def script_handler(events, context):
    instance_id = events["InstanceId"]
    instance_type = events["InstanceType"]

    ec2client = boto3.client('ec2')
    
    #stop the instance
    ec2client.stop_instances(InstanceIds=[instance_id])
    waiter = ec2client.get_waiter('instance_stopped')
    waiter.wait(InstanceIds=[instance_id])

    # change the instance type
    ec2client.modify_instance_attribute(InstanceId=instance_id, Attribute='instanceType', Value=instance_type)

    ec2client.start_instances(InstanceIds=[instance_id])
    waiter = ec2client.get_waiter('instance_running')
    waiter.wait(InstanceIds=[instance_id])

    return {
        'Output' : instance_id
    }
