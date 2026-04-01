Integer	li_fileNum, li_fileLength, li_return, li_recordNum, li_leer, li_error,_proc,li_pos,li_to,li_procesar,li_pos_lote,li_pos_renglon,li_pos_rechazo,li_cant_lotes = 0,li_cont
String		ls_campo, ls_pathname, ls_fileName, ls_no_lote, ls_mensaje,ls_file,ls_error,ls_ruta_bk,ls_ruta_arpob,ls_ruta_errores,ls_null,ls_nom_archivo,ls_fecha_resumen
String		ls_no_remesa, ls_compania, ls_sucursal, ls_usuario, ls_rechazo,ls_lote_cobtalot,ls_fecha_lote,ls_ruta_rechazos,ls_rep_dataobject,ls_tipo_proceso
Long		ll_row, ll_fila, ll_renglon,i,ll_row2,ll_secuencia,ll_rowm
Date		ld_fecha_lote
Dec{2}	ld_total_cobrado,ld_cobrado_lote,ld_sum_lote

datastore	lds_cobtalot,lds_reporte
str_file_list	lstr_files_aprob,lstr_files_rechazo,lstr_files_errores,lstr_files_tot,lstr_rutas

of_wait()
lds_cobtalot = CREATE Datastore
lds_cobtalot.DataObject = 'd_ayuda_cobtalot'
lds_cobtalot.SetTransObject(sqlca)

ll_rowm = idw_objeto.GetRow()

ll_row2 = lds_cobtalot.Retrieve()
ls_compania = g_globales.istr_usuario.compania
ls_sucursal = g_globales.istr_usuario.agencia
ls_usuario  = g_globales.istr_usuario.usuario
ld_fecha_lote = lds_cobtalot.object.fecha[lds_cobtalot.GetRow()]
ls_fecha_lote = String(ld_fecha_lote,'yyyymmdd')
ls_fecha_resumen = String(ld_fecha_lote,'ddmmyyyy')

//Ruta de Respositorio de Archivos de BK
istr_campos[1].campo = "codigo_parametro = 'ruta_tmp_bk_tcr'"
istr_campos[2].campo = ""
ls_ruta_bk	= trim(f_retornar_valor(istr_campos, "inspaag", "valor_parametro"))

//Ruta de Archivos de transacciones Aprobadas
istr_campos[1].campo = "codigo_parametro = 'ruta_aprob_tcr'"
istr_campos[2].campo = ""
lstr_rutas.as_filename[ upperbound( lstr_rutas.as_filename ) + 1 ]  = trim(f_retornar_valor(istr_campos, "inspaag", "valor_parametro"))

//Ruta de Archivos de Transacciones Declinadas
istr_campos[1].campo = "codigo_parametro = 'ruta_rech_tcr'"
istr_campos[2].campo = ""
lstr_rutas.as_filename[ upperbound( lstr_rutas.as_filename ) + 1 ]  = trim(f_retornar_valor(istr_campos, "inspaag", "valor_parametro"))

//Ruta de Archivos de Transacciones con Error
istr_campos[1].campo = "codigo_parametro = 'ruta_errores_tcr'"
istr_campos[2].campo = ""
lstr_rutas.as_filename[ upperbound( lstr_rutas.as_filename ) + 1 ]  = trim(f_retornar_valor(istr_campos, "inspaag", "valor_parametro"))

//Ruta de Archivos de Resumen de Proceso
istr_campos[1].campo = "codigo_parametro = 'ruta_summary_tcr'"
istr_campos[2].campo = ""
lstr_rutas.as_filename[ upperbound( lstr_rutas.as_filename ) + 1 ]  = trim(f_retornar_valor(istr_campos, "inspaag", "valor_parametro"))

Update cobtatra
	Set procesar       = 0,
	 	 motivo_rechazo = :ls_rechazo
 Using sqlca;
 

lstr_files_tot = uof_get_files(lstr_rutas,False)
li_to = UpperBound(lstr_files_tot.as_file)

//if ll_row2 <> li_to then
//	li_return = MessageBox('Seleccion de Archivos Kinpos', 'La cantidad de Archivos en la Carpeta de Aprobadas es Distinta a la Cantidad de Lotes, Por Favor Verifique', StopSign!)
//	return 1
//end if

for i = 1 to li_to
	ls_pathname = Trim(lstr_files_tot.as_file[i])
	ls_file = Trim(lstr_files_tot.as_filename[i])
	
	li_pos = Pos(ls_pathname,'.txt')
	if li_pos = 0 then
		continue
	end if
	// Procesa los Registros de Aprobadas

	if mid(upper(ls_file),1,15) = "KRPSIMP" + ls_fecha_lote then
		li_cant_lotes = li_cant_lotes + 1
		ls_lote_cobtalot = '00000' + string(li_cant_lotes)
		ls_lote_cobtalot = Right(ls_lote_cobtalot, 5)
		ls_rep_dataobject = 'd_cobr_tcr_procesados'
		li_procesar = 1
		ls_nom_archivo	= '05_Aprobadas_' + ls_lote_cobtalot + '.pdf'
		ls_tipo_proceso	= 'A'
		li_pos_lote		= 103
		li_pos_renglon	= 108

//		li_pos_lote		= 97
//		li_pos_renglon	= 102
		li_pos_rechazo	= 0

// Procesa los Registros de Declinadas
	elseif mid(upper(ls_file),1,27) = "KRPSDECLINEDKRPSIMP" + ls_fecha_lote then
		li_cant_lotes = li_cant_lotes + 1
		ls_lote_cobtalot = '00000' + string(li_cant_lotes)
		ls_lote_cobtalot = Right(ls_lote_cobtalot, 5)
		ls_rep_dataobject = 'd_cobr_tcr_rechazos'
		li_procesar = 0
		ls_nom_archivo	= '06_Rechazos_' + ls_lote_cobtalot + '.pdf'
		ls_tipo_proceso	= 'R'
		li_pos_lote		= 67
		li_pos_renglon	= 72
		li_pos_rechazo	= 86
		
//		li_pos_lote		= 59
//		li_pos_renglon	= 64
//		li_pos_rechazo	= 101

// Procesa los Registros de Error
	elseif mid(upper(ls_file),1,21) = "KRPSERKRPSIMP" + ls_fecha_lote then
		li_cant_lotes = li_cant_lotes + 1
		ls_lote_cobtalot = '00000' + string(li_cant_lotes)
		ls_lote_cobtalot = Right(ls_lote_cobtalot, 5)
		ls_rep_dataobject = 'd_cobr_tcr_errores'
		li_procesar = 0
		ls_nom_archivo	= '07_Errores_' + ls_lote_cobtalot + '.pdf'
		ls_tipo_proceso	= 'E'
		li_pos_lote		= 42
		li_pos_renglon	= 47
		li_pos_rechazo	= 61

// Procesa los Registros de Total
	elseif mid(upper(ls_file),1,21) = "KRPSTOTALTXNS" + ls_fecha_resumen then		
		li_cant_lotes = li_cant_lotes + 1
		ls_lote_cobtalot = '00000' + string(li_cant_lotes)
		ls_lote_cobtalot = Right(ls_lote_cobtalot, 5)
		ls_rep_dataobject = 'd_cobr_tcr_summary'
		li_procesar = 0
		ls_nom_archivo	= '04_Resumen_' + ls_lote_cobtalot + '.pdf'
		ls_tipo_proceso	= 'S'
		li_pos_lote		= 0
		li_pos_renglon	= 0
		li_pos_rechazo	= 0		
	end if
	
	li_fileNum  = FileOpen(ls_pathName, LineMode! , Read!, LockRead!, Replace!)
	If IsNull(li_fileNum) Or li_fileNum = -1 THEN
		li_return = MessageBox('Error de Actualización', 'No se Pudo Abrir el Archivo: '+ ls_file +', Por Favor Verifique', StopSign!)
			return 1
	End If
	li_leer = 1
	
	lds_reporte = create Datastore
	lds_reporte.DataObject = ls_rep_dataobject
	lds_reporte.SetTransObject(sqlca)
	
	Do Until li_leer = 0
		li_recordNum = FileRead(li_fileNum, ls_campo)
		If isNull(li_recordNum) Or li_recordNum = -1    Then
			
			li_return = MessageBox('Error de Actualización', + &
										  'Ocurrio un Error al Actualizar las Tarjetas Rechazadas, Por Favor Verifique', + & 
											StopSign!)
			return 1
		End If
		If li_recordNum = -100  THEN
			li_leer = 0
		Else			
			if li_pos_rechazo <> 0 then
				ls_rechazo     = MID(ls_campo, li_pos_rechazo, 50)
			end if
			
			if li_pos_renglon <> 0 then
				//LOTE VISA Y MASTERCARD
				ls_no_lote     = MID(ls_campo, li_pos_lote, 5)
				ll_renglon     = Long(MID(ls_campo, li_pos_renglon, 5))
				
				Update cobtatra
					Set procesar			= :li_procesar,
						 motivo_rechazo	= :ls_rechazo
				Where no_lote	= :ls_no_lote
					and renglon	= :ll_renglon
				  Using sqlca;
			end if
				
			li_error = uof_file_list('TCR',ls_tipo_proceso,ls_campo,lds_reporte)
		End If
	Loop
	
	// Se Cierra el Archivo del Banco
	li_recordNum = FileClose(li_fileNum)
	If IsNull(li_recordNum) Or li_recordNum = -1 THEN
		li_return = MessageBox('Error de Actualización', 'No se Pudo Cerrar el Archivo: ' +ls_file + ', Por Favor Verifique.' ,StopSign!)
		return 1
	End If
	
	 li_error = f_gen_bk_electronico(ls_pathname,ls_ruta_bk,ls_nom_archivo,'',lds_reporte,'')
	 destroy lds_reporte
	 
	 if li_error <> 0 then
		return 1
	end if
Next

select count(*)
  into :_proc
  from cobtatra
 where procesar = 1 Using sqlca;
 


if _proc = 0 then

	ls_mensaje = "Todos los registros estan rechazados o con error, No se creará la Remesa. Desea Continuar con el Proceso?"
	
	li_return = Messagebox('Cartas de Rechazo',ls_mensaje,Question!,YesNo!)

	if li_return = 2 then
		ROLLBACK USING SQLCA;
		Return 1
	end if

	DECLARE cob50b PROCEDURE FOR sp_cob50b (:ls_compania, :ls_sucursal, :ls_usuario) USING SQLCA;
	EXECUTE cob50b;
	FETCH cob50b INTO :li_error, :ls_mensaje, :ls_no_remesa;
	CLOSE cob50b;
	
	CHOOSE CASE li_error
		Case 1
			ROLLBACK USING SQLCA;
			MessageBox('Remesa de Tarjetas de Credito', ls_mensaje,  StopSign!)
			RETURN 1
		Case 0
			COMMIT USING SQLCA;
			MessageBox('Remesa de Tarjetas de Credito', ls_mensaje, Information!)
			Return 0
		Case else
			ROLLBACK USING SQLCA;
			f_errores(0, li_error, "", "")
			RETURN 1
	END CHOOSE
else
	////////////////////////********************Creacion de la Remesa de las transacciones Aprobadas*****************////////////////////////////////
	DECLARE cob50 PROCEDURE FOR sp_cob50(:ls_compania, :ls_sucursal, :ls_usuario,'V') USING SQLCA;
	EXECUTE cob50;
	FETCH cob50 INTO :li_error, :ls_mensaje, :ls_no_remesa;
	CLOSE cob50;
	
	CHOOSE CASE li_error
		Case 1
			ROLLBACK USING SQLCA;
			MessageBox('Remesa de Tarjetas de Credito', ls_mensaje,  StopSign!)
			RETURN 1
		Case 0
			//MessageBox('Remesa de Tarjetas de Credito', ls_mensaje, Information!)
	//		Return 0
		Case else
			ROLLBACK USING SQLCA;
			f_errores(0, li_error, "", "")
			RETURN 1
	END CHOOSE
	
	////////////////////////********************Creacion del Backup de Archivos del Proceso*****************////////////////////////////////
	lds_reporte = CREATE Datastore
	lds_reporte.DataObject = 'd_cobr_tcr_errores'
	lds_reporte.SetTransObject(sqlca)
	
	li_to = UpperBound(lstr_files_tot.as_file)
	
	for i = 1 to li_to
		ls_pathname = Trim(lstr_files_tot.as_file[i])
		ls_file = Trim(lstr_files_tot.as_filename[i])
		
		li_pos = Pos(ls_pathname,'.txt')
		if li_pos = 0 then
			continue
		end if
	
		li_error = f_gen_bk_electronico(ls_pathname,ls_ruta_bk,'',ls_file,lds_reporte,'M')
	
		if li_error <> 0 then
			ROLLBACK USING SQLCA;
			MessageBox('Respaldo de Archivos','Ha Ocurrido un error al momento de realizar el respaldo de los archivos de texto del proceso. Por Favor Verifique.',StopSign!)
			return 1
		end if
	next
	
	istr_campos[1].campo = "no_remesa = '" + ls_no_remesa + "'"
	istr_campos[2].campo = ""
	ld_total_cobrado	= dec(f_retornar_valor(istr_campos, "cobremae", "monto_chequeo"))
	
	ll_fila = idw_objeto.RowCount()
	ld_sum_lote = 0.00
	
	for li_cont = 1 to ll_fila
		
		ls_no_lote = trim(idw_objeto.Object.no_lote[li_cont])
		
		istr_campos[1].campo = "no_lote = '" + Trim(ls_no_lote) + "'"
		istr_campos[2].campo = "procesar = '1'"
		istr_campos[3].campo = ""
		
		ld_cobrado_lote = 0.00
		ld_cobrado_lote = f_sumar_valor(istr_campos, "cobtatra","monto")
		
		idw_objeto.Object.no_remesa[li_cont] = trim(ls_no_remesa)
		idw_objeto.Object.monto_cobrado[li_cont] = ld_cobrado_lote
		
		ld_sum_lote = ld_sum_lote + ld_cobrado_lote
	next
	
	
	
	If idw_objeto.Update() = 1 Then
	Else
		ROLLBACK USING SQLCA;
		MessageBox("Creación Remesa","Ha Ocurrido un Error al Momento de Actualizar la información de los Lotes. Intente Generar la Remesa Nuevamente.",StopSign!)
		Return 1
	End If	
	
	COMMIT USING SQLCA;
	MessageBox('Remesa de Tarjetas de Credito', ls_mensaje, Information!)
	
end if

/////////////////////////////*********************Procedure para generar Cartas de Rechazo********************/////////////////////////////////////
DECLARE sp_cob280 PROCEDURE FOR sp_cob280b (:ls_usuario) USING SQLCA;
EXECUTE sp_cob280;
  FETCH sp_cob280 INTO :ll_secuencia,:ls_error;
  CLOSE sp_cob280;

if ll_secuencia <> 0 then
	li_return = Messagebox('Cartas de Rechazo','No se han podido crear las cartas de Rechazo para envio al Cliente. Ha Ocurrido el Siguiente Error: ' + string (ll_secuencia) + &
															  ' . Desea Continuar con el Proceso?.',Question!,YesNo!)
	if li_return = 2 then
		ROLLBACK USING SQLCA;
		Return 1
	end if
//--end if   SD#4510 MARILUZ HGIRON 20/09/2022
else
	COMMIT USING SQLCA; 
end if

Return 0