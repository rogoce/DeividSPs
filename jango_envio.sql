Llamado desde PB

lb_valido = f_webservice_workflow_correo(trim(ls_html_body0), trim(ls_asunto),trim(ls_email),trim(ls_attachs),trim(ls_imagen),"express-relay.jangosmtp.net",ls_sender,"12345678.Com","587","jesusrbrito75",trim(ls_sender_dyn),ls_grupo_trans) 

Función en PB f_webservice_workflow_correo

OleObject  soapClient
any   la_rc
boolean lb_1 
STRING ip_adress
lb_1 = true

/*Recordar que los datos de la cadena debe ser de acuerdo al formato:
  as_cadena = 'iniciador|AMADO&&firma_sup|5.00&&' */

soapClient = CREATE OLEObject

la_rc = soapClient.ConnectToNewObject("MSSOAP.SoapClient30")
If (la_rc <> 0) Then
 Destroy(soapClient)	
 return false
 End If

la_rc = soapClient.MSSoapInit("http://10.4.1.37:90/WS_Control_Reservas/Service1.asmx?wsdl","","","")
		TRY 
			soapClient.EnvioMail(as_body, as_subject, as_to, as_adjunto, as_smtp, as_correo_from, as_clave_from, as_puerto, as_remitente_usuario, as_imagen, as_cc, as_grupo_tran)
		CATCH (RuntimeError e)
			lb_1 = false
		END TRY

soapClient.DisconnectObject()
Destroy(soapClient)

return lb_1

Función en .Net EnvioMail

        <WebMethod()> Public Function EnvioMail(ByVal body As String, _
                                                      ByVal Subject As String, _
                                                          ByVal To_s As String, _
                                                          ByVal _attachment As String, _
                                                          ByVal _smtp As String, _
                                                          ByVal CorreoFrom As String, _
                                                          ByVal ClaveFrom As String, _
                                                          ByVal Puerto As String, _
                                                          ByVal RemitenteUsuario As String, _
                                                          ByVal Imagen As String, _
                                                          ByVal Cc_s As String, _
                                                          ByVal Grupo As String) As String

            Dim correo As New MailMessage
            Dim smtp As New SmtpClient()
            Dim para() As String = To_s.Split(";")
            Dim cc() As String = Cc_s.Split(";")
            Dim adjuntos() As String = _attachment.Split("|")
            Dim imagenes() As String = Imagen.Split("|")
            Dim ii As Integer
            Dim adjunto As String
            Dim _imagen As String
            Dim body2 As String

			--Crear el Objeto MailMessage
            'correo.From = New MailAddress(CorreoFrom, RemitenteUsuario, System.Text.Encoding.UTF8)
            
			correo.From = New MailAddress(CorreoFrom)
            If UBound(para) = 0 Then
                correo.To.Add(para(0))
            Else
                For ii = 0 To UBound(para) - 1
                    If Trim(para(ii)) <> "" And Not IsDBNull(para(ii)) Then
                        correo.To.Add(para(ii))
                    End If
                Next
            End If

            If Trim(Cc_s) <> "" And Not IsDBNull(Cc_s) Then
                If UBound(cc) = 0 Then
                    correo.CC.Add(cc(0))
                Else
                    For ii = 0 To UBound(cc) - 1
                        correo.CC.Add(cc(ii))
                    Next
                End If
            End If
            If Trim(Grupo) <> "" And Not IsDBNull(Grupo) Then
                Subject = Subject & " {" & Grupo & "}"
            End If
            correo.SubjectEncoding = System.Text.Encoding.UTF8
            correo.Subject = Subject
            If Trim(body) <> "" And Not IsDBNull(body) Then
                correo.Body = body
            End If
            If Trim(Imagen) <> "" And Not IsDBNull(Imagen) Then
                _imagen = ImageToBase64(Imagen, System.Drawing.Imaging.ImageFormat.Jpeg)
                body2 = Replace(body, "codigoimagen", _imagen)
                correo.Body = body2
                'correo.Attachments.Add(New Attachment(Imagen))
            End If
            If Trim(_attachment) <> "" And Not IsDBNull(_attachment) Then
                If UBound(adjuntos) = 0 Then
                    adjunto = adjuntos(0)
                    correo.Attachments.Add(New Attachment(adjunto))
                Else
                    For ii = 0 To UBound(adjuntos) - 1
                        adjunto = adjuntos(ii)
                        correo.Attachments.Add(New Attachment(adjunto))
                    Next
                End If
                ' correo.Attachments.Add(New Attachment(_attachment))
            End If
            correo.BodyEncoding = System.Text.Encoding.UTF8
            correo.IsBodyHtml = True '(formato tipo web o normal: true = web)
            correo.Priority = MailPriority.High '>> prioridad

            smtp.Credentials = New System.Net.NetworkCredential(RemitenteUsuario, ClaveFrom)
            smtp.Port = Puerto
            smtp.Host = _smtp
            smtp.EnableSsl = True

            smtp.Send(correo)
            correo.Dispose()

            EnvioMail = "Ok"
        End Function



