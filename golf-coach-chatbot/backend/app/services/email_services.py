import os.path
import base64
import mimetypes
import httplib2

from email.mime.multipart import MIMEMultipart
from email.mime.base import MIMEBase
from email.mime.text import MIMEText

from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

# If modifying these scopes, delete the file token.json.
SCOPES = ["https://www.googleapis.com/auth/gmail.send"]

def getCredentials():
  """Shows basic usage of the Gmail API.
  Lists the user's Gmail labels.
  """
  creds = None
  # The file token.json stores the user's access and refresh tokens, and is
  # created automatically when the authorization flow completes for the first
  # time.
  basedir = os.path.abspath(os.path.dirname(__file__))
  if os.path.exists("token.json"):
    creds = Credentials.from_authorized_user_file("token.json", SCOPES)
  # If there are no (valid) credentials available, let the user log in.
  if not creds or not creds.valid:
    if creds and creds.expired and creds.refresh_token:
      creds.refresh(Request())
    else:
      flow = InstalledAppFlow.from_client_secrets_file(
          basedir + "/credentials.json", SCOPES
      )
      creds = flow.run_local_server(port=0)
    # Save the credentials for the next run
    with open("token.json", "w") as token:
      token.write(creds.to_json())
  return creds

def createMessage(sender, to, subject, msgPlain):
  message = MIMEMultipart("alternative")
  message["to"] = to
  message["from"] = sender
  message["subject"] = subject

  message.attach(MIMEText(msgPlain, 'plain'))

  raw = base64.urlsafe_b64encode(message.as_bytes())
  raw = raw.decode()
  body = {"raw": raw}
  return body

def SendMessage(sender, to, subject, msgPlain):
    credentials = getCredentials()
    service = build("gmail", "v1", credentials=credentials)
    message1 = createMessage(sender, to, subject, msgPlain)
    sendMessageInternal(service, "me", message1)

def sendMessageInternal(service, user_id, message):
    try:
        message = (service.users().messages().send(userId=user_id, body=message).execute())
        return message

    except HttpError as error:
      print('An error has occured: %s' % error)

def sendResetEmail(userEmail, recoveryNumber):
    to = userEmail
    sender = "golf.swing.reset.password@gmail.com"
    subject = "Golf Swing Analysis Password Recovery"
    msgPlain = f'Your recovery number is : {recoveryNumber}\nIf you did not request a password reset, no action is needed.'
    SendMessage(sender, to, subject, msgPlain)