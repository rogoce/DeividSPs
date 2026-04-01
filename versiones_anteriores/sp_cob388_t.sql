
-- Procedimiento que Genera Los Avisos de Cancelación por Campaña
-- Creado    : 21/01/2013 - Autor: Roman Gordon generasion de Filtros
-- Modificado : 22/10/2018 - Henry Giron - Se genera gestion y correo psra cobros
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_cob388;
create procedure 'informix'.sp_cob388(a_no_aviso char(10), a_usuario char(8)) 
returning	smallint,
			varchar(100);

define _desc_gestion		varchar(200);
define _error_desc			varchar(100);
define _email_cli			varchar(100);
define _email_corr			varchar(100);
define _nom_acreedor		varchar(50);
define _nombre1				varchar(50);
define _nombre2				varchar(50);
define _cargo1				varchar(50);
define _cargo2				varchar(50);
define _tipo_gestion		varchar(100);
define _tipo_email			varchar(20);
define _no_documento		char(18);
define _cod_contratante		char(10);
define _no_reclamo			char(10);
define _no_poliza			char(10);
define _user_added			char(8);
define _usuario1			char(8);
define _usuario2			char(8);
define _periodo				char(7);
define _cod_agente			char(5);
define _cod_ramo			char(3);
define _estatus_poliza		char(1);
define _desmarcar			char(1);
define _clase				char(1);
define _null				char(1);
define _porc_partic			dec(5,2);
define _porc_comis			dec(5,2);
define _monto_recibo		dec(16,2);
define _impuesto			dec(16,2);
define _factor				dec(16,2);
define _saldo				dec(16,2);
define _prima				dec(16,2);
define _tm_fecha_efectiva	smallint;
define _tipo_aviso			smallint;
define _cnt_filas			smallint;
define _error_code			integer;
define _error_isam			integer;
define _renglon				integer;
define _fecha_vence			date;
define _fecha_hoy			date;
define _fecha				date;
define _fecha_gestion		datetime year to second;
define _cod_acreedor		char(10);
define _email_acreedor	    varchar(100);
define _estatus			    char(1);

set isolation to dirty read;

--set debug file to 'sp_cob388.trc';
--trace on ;

begin

on exception set _error_code, _error_isam, _error_desc
 	return _error_code, _error_desc;
end exception 

let _tipo_aviso = 17;
let _fecha_hoy = current;

select trim(nombre1),
	   trim(cargo1),
	   trim(usuario1),
	   trim(nombre2),
	   trim(cargo2),
	   trim(usuario2),
	   tm_fecha_efectiva
  into _nombre1,
	   _cargo1,
	   _usuario1,
	   _nombre2,
	   _cargo2,
	   _usuario2,
	   _tm_fecha_efectiva
  from avicanpar
 where cod_avican  = a_no_aviso;

if _usuario1 is null or trim(_usuario1) = '' then
	let _cnt_filas = 0;
else
	let _cnt_filas = 1;
end if	
  
if _usuario2 is null  or trim(_usuario2) = '' then
	let _cnt_filas = 0;
else
	let _cnt_filas = 2;
end if	

if _cnt_filas = 0 then
	return 1,'Las Firmas de en Aviso de Cancelacion no han sido Capturadas.';
end if  

if _tm_fecha_efectiva is null or _tm_fecha_efectiva = 0 then
	let _fecha_vence = _fecha_hoy + 10 units day;
else
	let _fecha_vence = _fecha_hoy + _tm_fecha_efectiva units day;
end if	

foreach
	select no_poliza,
		   no_documento,
		   cod_ramo,
		   cod_agente,
		   renglon,
		   estatus_poliza,
		   saldo,
		   desmarca,
		   clase,
		   nombre_acreedor,
		   cod_acreedor
	  into _no_poliza,
		   _no_documento,
		   _cod_ramo,
		   _cod_agente,
		   _renglon,
		   _estatus_poliza,
		   _saldo,
		   _desmarcar,
		   _clase, _nom_acreedor,_cod_acreedor
	  from avisocanc
	 where no_aviso = a_no_aviso

	if _saldo <= 0 then
		continue foreach;
	end if

	if _desmarcar = '0' or _desmarcar is null then 
		continue foreach;
	end if		

	select cod_contratante
	  into _cod_contratante
	  from emipomae
	 where no_poliza = _no_poliza;

	select trim(email_cli)
	  into _email_cli
	  from avisocanc
	 where no_aviso = a_no_aviso
	   and renglon = _renglon
	   and no_documento = _no_documento
	   and email_cli is not null
	   and email_cli not like '%/%'
	   and email_cli <> ''
	   and email_cli like '%@%'
	   and email_cli not like '@%'
	   and email_cli not like '% %'
	   and email_cli not like '%,%';

	if _email_cli is null then 
		let _email_cli = '';
	end if	

	let _tipo_gestion = 'CLIENTE';
	let _tipo_email = '';
    call sp_cob776(_no_poliza,_renglon,a_no_aviso) returning _clase;

	if _clase = '1' then
		if _email_cli <> '' then  -- se valida el correo
			let _tipo_email = '  POR CORREO';
		else			
			let _tipo_email = '  POR IMPRESORA';
		end if
	elif _clase = '2' then
		let _tipo_email = '  POR IMPRESORA';      
	end if
	{
	--Inserción de Tabla Temporal para acreedores
	call sp_cob389(a_no_aviso,_no_poliza,a_usuario) returning _error_code,_error_desc;
	if _error_code <> 0 then
		return _error_code, _error_desc;
	end if		
}
	if _estatus_poliza = '1' then
		let _desc_gestion = 'SE EMITIO AVISO DE CANCELACION AL ' || trim(_tipo_gestion) ||' '|| trim(_tipo_email);
	else
		let _desc_gestion = 'SE REALIZO CARTA 48 HORAS. ' || trim(_tipo_gestion) ||' '|| trim(_tipo_email) ;
	end if

	let _desc_gestion = Trim(_desc_gestion) || ' - Ref.: ' || trim( a_no_aviso);

	if _email_cli <> '' and _email_cli is not null and _clase = '1' then	
		-- Gestion en Cobros de Correo (Cliente)
		let _fecha_gestion = current;	
		let _email_cli = trim(_email_cli)||"; avisos@asegurancon.com;" ;
		call sp_par316('00010',_email_cli,a_no_aviso,_renglon) returning _error_code,_error_desc; 

		if _error_code <> 0 then
			return _error_code, _error_desc;
		end if
	end if	
	
    let _fecha_gestion = current;
	insert into cobgesti (
						no_poliza, 
						fecha_gestion, 
						desc_gestion, 
						user_added,
						cod_pagador,
						no_documento,
						tipo_aviso)
	values (_no_poliza,
						_fecha_gestion,
						_desc_gestion, 
						a_usuario,
						_cod_contratante,
						_no_documento,
						_tipo_aviso);
	
	foreach
		select no_reclamo
		  into _no_reclamo
		  from recrcmae
		 where actualizado = 1
		   and no_documento in (_no_documento)
		   and estatus_reclamo = 'A'

			insert into recnotas (
						no_reclamo,
						fecha_nota, 
						desc_nota, 
						fecha_aviso,
						user_added, 
						flag_web_corr)
			values (
						_no_reclamo, 
						_fecha_gestion, 
						_desc_gestion, 
						_fecha_hoy, 
						a_usuario,1);
			
	end foreach

	-- Gestion en Cobros de Correo (Corredor)
	let _email_corr = '';

	select trim(email_cobros)
	  into _email_corr
	  from agtagent
	 where cod_agente = _cod_agente;

	if _email_corr <> '' and _email_corr is not null then
		let _tipo_email = ' POR CORREO';
	else
		let _tipo_email = ' POR IMPRESORA';
	end if	
	
	if _email_corr <> '' and _email_corr is not null then			
		let _fecha_gestion = current;
		let _email_corr = trim(_email_corr)||"; avisos@asegurancon.com;" ;
		call sp_par316('00011',_email_corr,a_no_aviso,_renglon) returning _error_code,_error_desc; 

		if _error_code <> 0 then
			return _error_code, _error_desc;
		end if	
	end if	
	
	let _tipo_gestion = 'CORREDOR';

	if _estatus_poliza = '1' then
		let _desc_gestion = 'SE EMITIO AVISO DE CANCELACION AL ' || trim(_tipo_gestion)||' '||trim(_tipo_email);
	else
		let _desc_gestion = 'SE REALIZO CARTA 48 HORAS. ' || trim(_tipo_gestion)||' '||trim(_tipo_email) ;
	end if
	let _desc_gestion = Trim(_desc_gestion) || ' - Ref.: ' || trim( a_no_aviso);

    let _fecha_gestion = current + 1 units second;
	insert into cobgesti (
			no_poliza, 
			fecha_gestion, 
			desc_gestion, 
			user_added,
			cod_pagador,
			no_documento,
			tipo_aviso)
	values (_no_poliza,
			_fecha_gestion,
			_desc_gestion, 
			a_usuario,
			_cod_contratante,
			_no_documento,
			_tipo_aviso);

	update avisocanc
	   set estatus  = 'I',
		   fecha_imprimir  = _fecha_hoy,
		   user_imprimir  = a_usuario,
		   fecha_vence  = _fecha_vence,
		   marcar_entrega = '0'
	 where no_aviso = a_no_aviso 
	   and no_poliza = _no_poliza 
	   and renglon = _renglon; 			

	if _estatus_poliza = '1' then -- Aviso de cancelacion
		update emipomae 
		   set carta_aviso_canc = 1,
			   fecha_aviso_canc = _fecha_hoy
		 where no_poliza = _no_poliza;
	else    -- Carta de prima ganada
		update emipomae 
		   set carta_prima_gan = 1,
			   fecha_prima_gan = _fecha_hoy
		 where no_poliza = _no_poliza;
	end if
	
	if _nom_acreedor <> '... SIN ACREEDOR ...' and _nom_acreedor is not null then 
	   let _tipo_gestion = 'ACREEDOR: ';
		if _estatus_poliza = '1' then
			let _tipo_gestion = trim(_tipo_gestion)||trim(_nom_acreedor);
			let _desc_gestion = 'SE EMITIO AVISO DE CANCELACION AL '|| trim(_tipo_gestion);  
			let _desc_gestion = Trim(_desc_gestion) || ' - Ref.: ' || trim(a_no_aviso);			
			let _fecha_gestion = current + 2 units second;
			insert into cobgesti (
					no_poliza, 
					fecha_gestion, 
					desc_gestion, 
					user_added,
					cod_pagador,
					no_documento,
					tipo_aviso)
			values (
					_no_poliza,
					_fecha_gestion,
					_desc_gestion, 
					a_usuario,
					_cod_contratante,
					_no_documento,
					_tipo_aviso);
		end if
		
		let _email_acreedor = '';	
		
		select email 
		into  _email_acreedor
		from emiacre 
		where cod_acreedor = _cod_acreedor;;
{
DOS ESTADOS MAS:
E -	SE ENVIA POR CORREO Electronico EL AVISO AL CLIENTE Y impresion del ACREEDOR.	
B -	Correo Certificado para cliente y @ al acreedor	

		if (_email_acreedor is not null or _email_acreedor <> '')  then
		
				if  _clase = 2 then
					let _estatus = 'B';
				else
					let _estatus = 'E';
				end if
				
				update avisocanc
				   set estatus  = _estatus
				 where no_aviso = a_no_aviso 
				   and no_poliza = _no_poliza 
				   and renglon = _renglon; 	
	   
		end if
		
		
	end if
}	

	
end foreach

return 0,'Exito';
end
end procedure 