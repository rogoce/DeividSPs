-- Procedimiento Genera Proceso de Cese Automatico de Avisos de Cancelacion.
-- Creado     : 18/06/2019  -- Autor: Henry Giron.	
-- execute procedure sp_cob773()
-- SIS v.2.0 -- DEIVID, S.A.
Drop procedure sp_cob773;
create procedure "informix".sp_cob773()
returning smallint,Char(255);

define _no_documento	char(20);
define _prima_bruta		dec(16,2);
define _no_poliza		char(10);
define _no_unidad		char(5);
define _no_endoso		char(5);
define _no_factura		char(10);
define _user_ejecuto	char(8);
define _supervisor  	char(8);
define _fecha_end_canc	date;
define _cancelada		smallint;
define _fecha_ejecuto	date;
define _fecha_perdida	date;
define _fecha_vence 	date;

define _renglon			integer;
define _cnt_cancela     integer;
define _referencia      CHAR(15);
define _fecha_gestion	datetime year to second;

-- Vigencia Actual
define _no_poliza2		char(10);
define _estatus_poliza2 smallint;
define _desc_estatus	char(10);

define _error			integer;
define _error_isam		integer;
define _error_desc		char(255);

define _descripcion		char(255);
define _cantidad		integer;
define _cod_cliente		char(10);
define _saldo_canc		dec(16,2);
define _estatus_poliza	char(1);
define _desc_gestion	varchar(200);
define _tipo_aviso		smallint;
define _cod_contratante	char(10);
define _dias			integer;
define _dias_cese		integer;
define _fecha_actual	date;
define _fecha_15d		date;
define _fecha_marcar    date;
define _email_cli		varchar(100);
define _error_code		integer;
define _marcar          char(1);
define _cod_ramo        char(3);
define _enviado		    integer;
define _cnt_cese	    integer;
define _fecha_suspension	date;

set isolation to dirty read;
--return 0,"Realizado Exitosamente. En Base de prueba de Sistema.";
drop table if exists temp_msg;	
 CREATE TEMP TABLE temp_msg
           (no_aviso		 CHAR(15),
            no_poliza		 CHAR(10),
			no_documento 	 CHAR(20),
			mensaje          CHAR(200),
        PRIMARY KEY(no_aviso,no_poliza,no_documento)) 
        WITH NO LOG;

CREATE INDEX idx1_temp_msg ON temp_msg(no_aviso);
CREATE INDEX idx2_temp_msg ON temp_msg(no_poliza);
CREATE INDEX idx3_temp_msg ON temp_msg(no_documento);

set debug file to "sp_cob773.trc";
trace on;

--begin work;
begin
on exception set _error, _error_isam, _error_desc
	--rollback work;
	return _error, _error_desc;
end exception

let _cantidad     = 0;
let _saldo_canc   = 0;
let _tipo_aviso   = 17;
let _fecha_actual = sp_sis26();
let _enviado = 0;
let _cnt_cese = 0;
let _error  = 0;
let _descripcion = "Cese de Cobertura Diario ";
--let _fecha_actual	= _fecha_actual - 1 units day;
--let _fecha_actual	= mdy(month(_fecha_actual),day(_fecha_actual),year(_fecha_actual)); 

 	update parmailsend 
	   set enviado = 1 
	 where cod_tipo in ('00010','00011') 
	   and enviado = 0 ;	   

select valor_parametro
	  into _dias_cese
	  from inspaag
	 where codigo_parametro = 'par_cese';	  
	 
select firma_end_canc
  into _supervisor
  from parparam
 where cod_compania = "001";	 
	 
foreach	
 select no_aviso,
        no_poliza,
		user_ejecuto,
		no_documento,
		fecha_vence,
		cod_contratante,
		fecha_ejecuto,
		trim(email_cli),
		estatus_poliza,
		renglon,
		marcar_entrega,
		fecha_marcar
   into _referencia,
        _no_poliza, 
		_user_ejecuto, 
		_no_documento, 
		_fecha_vence,   
		_cod_cliente, 
		_fecha_ejecuto,
		_email_cli,
		_estatus_poliza,
		_renglon,
		_marcar,
		_fecha_marcar
   from avisocanc 
  where ejecuto = "1"  
    and fecha_diario is null    	
	and fecha_marcar = _fecha_actual
	{
	   let _enviado = 0;
	Select count(* )
	  into _enviado
	  from parmailsend a, parmailcomp b
	 where a.cod_tipo  = '00010'
	   and a.secuencia = b.mail_secuencia
	   and date(a.date_added) = _fecha_ejecuto
	   and b.no_remesa = _referencia
	   and b.renglon = _renglon;
	   
		if  _enviado is null or _enviado = 0 then
			continue foreach;
		end if
	}
	let _dias = 15;
	{
	call sp_sis388(_fecha_ejecuto,_fecha_actual) returning _dias;	
    let _dias = _dias;
	  let _dias_cese = _dias_cese;
	if _dias <= _dias_cese then
		if _marcar = 1 then 
			call sp_sis388a(_fecha_ejecuto,_dias_cese) returning _fecha_15d;	
			
			if _fecha_15d is not null then								
				
			    select fecha_suspension 
				  into _fecha_suspension
				  from emipoliza
				 where no_documento = _no_documento;
				 
				 if _fecha_suspension is not null then
						--if _fecha_suspension > _fecha_actual then
						   let _fecha_15d = _fecha_suspension;
					   --end if
				 end if				 
				 
			end if						
			
			 update avisocanc 
			    set marcar_entrega = '1',
				    fecha_marcar = _fecha_15d,
					user_marcar = _supervisor, --_user_ejecuto
					estatus = 'M'
			  where ejecuto = "1"  
				and fecha_diario is null 
                and marcar_entrega = 1
				and no_aviso = _referencia
				and renglon = _renglon;					
				
		end if
		continue foreach;
	end if				
	}	
	select cod_contratante, cod_ramo
	  into _cod_contratante, _cod_ramo
	  from emipomae
	 where no_poliza = _no_poliza;	 	 
	 
	 let _cnt_cancela = 0;
	 
 select count(*)
   into _cnt_cancela
   from emipouni a,emipomae b
  where a.cod_producto in ('04561')
    and a.no_poliza = b.no_poliza
	and a.no_poliza = _no_poliza
    and b.estatus_poliza = 1;

	if _cnt_cancela  IS NULL  then
		let _cnt_cancela = 0;
	end if

	 
	 if _cod_ramo = '020' and _cnt_cancela > 0 then
		let _desc_gestion = 'PÓLIZA CANCELADA POR FALTA DE PAGO A LA POLIZA ' || trim(_no_documento);					
		call sp_cob252(_no_poliza,_referencia,_supervisor) returning _error, _descripcion;
	end if
	
	if _cod_ramo = '002' or (_cod_ramo = '020'and _cnt_cancela = 0 ) then
		let _desc_gestion = 'LEY SOBAT - DISMINUCIÓN DE COBERTURAS POR FALTA DE PAGO A LA POLIZA ' || trim(_no_documento);					
		call sp_pro574(_no_poliza,_supervisor,0.00,'001') returning _error, _descripcion, _no_endoso;		
	end if
	
	
	if _error <> 0 then
				--rollback work;
				let _descripcion = "Cese de Cobertura Diario ";

				INSERT INTO temp_msg(
							no_aviso,		
							no_poliza,		
							no_documento, 	
							mensaje	)
					VALUES	(_referencia, 
							_no_poliza,
							_no_documento,
							_descripcion 
							);

				exit foreach;
	else	
		
		let _desc_gestion = Trim(_desc_gestion) || ' - Ref.: ' || trim( _referencia);
        let _cnt_cese = _cnt_cese + 1;
		let _email_cli = replace(_email_cli," ","");
		if _email_cli <> '' and _email_cli is not null then	
			-- Gestion en Cobros de Correo (Cliente) 
			let _fecha_gestion = current;	
			let _email_cli = trim(_email_cli); --||"; avisos@asegurancon.com;" ;
			call sp_par316('00013',_email_cli,_referencia,_renglon) returning _error_code,_error_desc; 

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
					_supervisor, --_user_ejecuto,
					_cod_contratante,
					_no_documento,
					_tipo_aviso);					
					
			 update avisocanc 
			    set fecha_diario = date(_fecha_gestion)
			  where ejecuto = "1"  
				and fecha_diario is null 
                and marcar_entrega = '1'
				and no_aviso = _referencia
				and renglon = _renglon;										
				
	end if					

end foreach
let _error  = _error ;
let _descripcion = _descripcion;

trace off;
if _error <> 0 then
   foreach
		select trim(no_documento),trim(mensaje)
		  into _no_documento,_descripcion
		  from temp_msg		 
		  exit foreach;
   end foreach
   rollback work;
   drop table if exists temp_msg;
	return 1,"Error "||trim(_descripcion)||". Poliza: "||trim(_no_documento) ;
else
	if _cnt_cese > 0 then
		--commit work;
	end if
	
	drop table if exists temp_msg;	

	return 0,""||trim(_descripcion)||" - Realizado Exitosamente.";
end if

end 



end procedure
 
 		