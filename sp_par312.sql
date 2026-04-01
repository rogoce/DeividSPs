-- Procedimiento que Verifica si la remesa es aplicable para el envio de comprobante electronico 	
-- Creado    : 24/11/2010 - Autor: Roman Gordon
-- execute procedure sp_par312()

drop procedure sp_par312;
create procedure sp_par312(
a_no_remesa	char(10))
returning	smallint,	--aplica o no para envio
			smallint;	--renglones

define _secuencia		integer;
define _secuencia_comp	integer;
define _renglon			smallint;
define _flag			smallint;
define _comp_electr		smallint;
define _cant_renglon	smallint;
define _cant_err		smallint;
define _fecha_hoy		date;
define _cod_chequera	char(3);
define _periodo			char(8);
define _cod_cliente		char(10);
define _nom_cliente		char(50);
define _email			varchar(150);

set isolation to dirty read;
--set debug file to "sp_par312.trc"; 
--trace on;

let _fecha_hoy = today;

Select cod_chequera
  into _cod_chequera
  from cobremae
 where no_remesa = a_no_remesa
   and cod_banco = '146';

Select comprobante_electronico
  into _comp_electr
  from chqchequ
 where cod_banco    = '146'
   and cod_chequera = _cod_chequera;

if _comp_electr = 1 or a_no_remesa in ('1788202','1794092','1797664','1800875','1802131') then
	let _flag = 1;
	Select count(*)
  	  into _cant_renglon
  	  from cobredet
 	 where tipo_mov = 'P'
 	   and no_remesa = a_no_remesa;

	if _cant_renglon > 0 then

		foreach
			Select renglon
			  into _renglon
			  from cobredet
			 where tipo_mov = 'P'
			   and no_remesa = a_no_remesa
			 order by renglon
			
				call sp_cob255('001','001',a_no_remesa,_renglon,_fecha_hoy)
				returning _nom_cliente,
						  _email,
						  _cod_cliente;
	
				if (trim(_email) is null or trim(_email) = '') then
					continue foreach;
				end if
				
				if a_no_remesa in ('1788202','1794092','1797664','1800875','1802131') then
					let _email = 'rgordon@asegurancon.com';
				end if
				
				select count(*)
				  into _cant_err
				  from parmailerr
				 where email = _email;
				 
				if _cant_err is null then
					let _cant_err = 0;
				end if

				if _cant_err = 0 then
                    if _cod_chequera in ('029','030','031') then -- REMESA VISA, REMESA ACH, REMESA AMERICAN -- ID de la solicitud	# 6411
						call sp_par310('00047',_email,'1') returning _secuencia;
					else
						call sp_par310('00004',_email,'1') returning _secuencia;
					end if	
					let _secuencia_comp = sp_sis149();

					insert into parmailcomp(secuencia,no_remesa,renglon,mail_secuencia,asegurado)
					values (_secuencia_comp, a_no_remesa, _renglon, _secuencia, _cod_cliente);
				end if
		end foreach;
	end if
else  
	let _cant_renglon = 0;
	let _flag = 0;
end if

return _flag,
	   _cant_renglon;

End Procedure	  