-- Cargando la tabla parmailsend con datos de polizas por vencer de fianza
-- Federico Coronado 15/07/2013 


drop procedure sp_pro581;
create procedure sp_pro581()
RETURNING SMALLINT, CHAR(30);

DEFINE r_error        	integer;
DEFINE r_error_isam   	integer;
DEFINE r_descripcion  	CHAR(30);
Define _html_body		char(512);
define _secuencia       integer;
define _secuencia2      integer;
define ls_e_mail        varchar(50);
define ls_e_mail2        varchar(50);
define _fecha_actual    date;
define _no_poliza      varchar(10);
define _cod_contratante varchar(10);
define _cod_pagador     varchar(10);
define _sender          varchar(100);
define _no_documento    varchar(15);
define _nombre          varchar(100);
define _cantidad,_dia,_mes        smallint;
define _email_final     char(384);
define _email_climail   varchar(50);
define _saldo           dec(16,2);
define _prima           dec(16,2);
define _prima_porc		dec(16,2);

BEGIN
ON EXCEPTION SET r_error, r_error_isam, r_descripcion
 	RETURN r_error, r_descripcion;
END EXCEPTION

set isolation to dirty read;

LET r_error       = 0;
LET r_descripcion = 'Actualizacion Exitosa ...';

--set debug file to "sp_pro581.trc"; 
--trace on;

LET _sender = "";
let _fecha_actual = sp_sis26();
let _dia = day(_fecha_actual);
let _mes = month(_fecha_actual);

if _dia in(29,30,31) then
    if _mes = 2 then
		let _fecha_actual = mdy(month(_fecha_actual), 28, year(_fecha_actual));
	elif _mes = 1 and _dia in(30,31) then
		let _fecha_actual = mdy(month(_fecha_actual), 28, year(_fecha_actual));
	else
		let _fecha_actual = mdy(month(_fecha_actual), 30, year(_fecha_actual));
	end if
end if	
let _fecha_actual = _fecha_actual + 1 units month;

let ls_e_mail = "";
let ls_e_mail2 = "";
let _email_final = '';
let _email_climail = '';

foreach
	select no_poliza,
		   no_documento,
		   cod_contratante,
		   cod_pagador,
		   prima_bruta
	  into _no_poliza,
	       _no_documento,
		   _cod_contratante,
		   _cod_pagador,
		   _prima
	 from emipomae
	 where cod_ramo = '008'
	   and vigencia_final >= _fecha_actual
	   and vigencia_final <= _fecha_actual
	   and actualizado = 1
	   and no_renovar  = 0
	   and incobrable  = 0
	   and abierta     = 0
	   and renovada    = 0
	   and estatus_poliza in (1,3)
	   
		--Buscar el saldo de la poliza
		call sp_cob85('001','001',_no_documento) returning _saldo;
		
		--si el saldo es 10% mayor que la prima bruta entonces se excluye del inf.			
		let _prima_porc = _prima * 0.10;
	   	
		if _saldo > 0 then
			if _saldo > _prima_porc then
				continue foreach;		
			end if
		end if
	   
	 
	select count(*)
	  into _cantidad
	  from parmailcomp
	 where no_remesa = _no_poliza
	   and no_documento = _no_documento;
	 
	if _cantidad = 0 then
		select e_mail,
			   nombre 
		  into ls_e_mail,
			   _nombre 
		  from cliclien 
		 where cod_cliente = _cod_contratante;

		select e_mail 
		  into ls_e_mail2
		  from cliclien 
		 where cod_cliente = _cod_pagador;
		 
		if ls_e_mail <> '' or ls_e_mail2 <> '' then

			let _email_final = trim(ls_e_mail);
			
			if ls_e_mail <> ls_e_mail2 then
				let _email_final = _email_final || ";" || trim(ls_e_mail2);			
			end if

			foreach
				select email
				  into _email_climail
				  from climail
				 where cod_cliente = _cod_contratante

				let _email_climail = trim(_email_climail);
				let ls_e_mail      = trim(ls_e_mail);                
				
				if ls_e_mail <> _email_climail then
					let _email_final   = trim(_email_final) || ';' || trim(_email_climail);
				end if
            end foreach
			
			
			foreach
				select email
				  into _email_climail
				  from climail
				 where cod_cliente = _cod_pagador

				let _email_climail = trim(_email_climail);
				let ls_e_mail2      = trim(ls_e_mail2);                
				
				if ls_e_mail2 <> _email_climail then
					let _email_final   = trim(_email_final) || ';' || trim(_email_climail);
				end if
            end foreach
			
			-- 00029 tipo nota de apertura email que se envia a los clientes que se les abrio el reclamo
			let _secuencia = sp_par336 ('00042', _email_final, 0);

			Select max(secuencia)
			  into _secuencia2
			  from parmailcomp;

			if _secuencia2 is null then
				let _secuencia2 = 0;
			end if

			let _secuencia2 = _secuencia2 + 1;

			insert into parmailcomp(
			secuencia,
			no_documento,
			asegurado,
			no_remesa,
			renglon,
			mail_secuencia)
			values(
			_secuencia2,
			_no_documento,
			_nombre,
			_no_poliza,
			0,
			_secuencia);
		end if

	end if
END FOREACH

RETURN r_error, r_descripcion  WITH RESUME;

END
end procedure