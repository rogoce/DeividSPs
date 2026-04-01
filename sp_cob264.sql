-- Proceso Generar un Comprobante de pago a requerimiento
-- Creado por :     Roman Gordon	27/01/2011
-- SIS v.2.0 - DEIVID, S.A.


Drop Procedure sp_cob264;

Create Procedure "informix".sp_cob264(a_no_documento char(20), a_no_remesa char(10))
Returning	smallint,-- motivo de rechazo
		   	char(10); --cod_cliente	

			
Define _renglon			smallint;
Define _no_poliza		char(10);
Define _secuencia_email	integer;
Define _secuencia		integer;
Define _cod_cliente		char(10);
Define _email			char(100);
Define _existe			smallint;
Define _habilitar		smallint;
Define _mail_err		smallint;

SET ISOLATION TO DIRTY READ;

--set debug file to "sp_cob264.trc";
--trace on;

let _renglon = 0;
let _habilitar = 0;
foreach
	Select no_poliza
	  into _no_poliza
	  from emipomae
	 where no_documento = a_no_documento

		Select count(*)
		  into _existe
		  from cobredet
		 where no_poliza = _no_poliza
		   and no_remesa = a_no_remesa;

		if _existe > 0 then
			Select renglon
			  into _renglon
			  from cobredet
			 where no_poliza	= _no_poliza
			   and no_remesa	= a_no_remesa;
			exit foreach;
		end if	
end foreach



if _renglon = 0 then

	-- JEPEREZ #1659# Habilitar el proceso de generación de comprobantes de pago, para los tipos de Remesa COMPROBANTES, Movimientos: Pago de Deducible / Pago de Recupero / Pago de Salvamento. 
		Select count(*)
		  into _habilitar
		  from cobremae a,cobredet b
		 where b.doc_remesa = a_no_documento
           and a.no_remesa = b.no_remesa
		   and b.no_remesa =  a_no_remesa
           and a.tipo_remesa in ('C')
           and b.tipo_mov in ('D','S','R');
		   
		if _habilitar > 0 then	   
			return 4,'';	
		else				   
			return 1,'';	
		end if		
end if

Select cod_pagador
  into _cod_cliente
  from emipomae
 where no_poliza = _no_poliza;

Select trim(e_mail)
  into _email
  from cliclien
 where cod_cliente = _cod_cliente;

Select count(*)
  into _mail_err
  from parmailerr 
 where email = _email;

if _mail_err > 0 then
	return 3,_cod_cliente;
end if

{if _email is null or _email = '' then
	if _cod_cliente = '252130' then
	else
		return 3,_cod_cliente;		
	end if
	
end if}

{CALL sp_par310('00004',_email,1) RETURNING _secuencia_email;

if _secuencia_email = 0 then
	return 2,'';
end if

Select max(secuencia) + 1
  into _secuencia
  from parmailcomp;

insert into parmailcomp(secuencia,no_remesa,renglon,mail_secuencia,asegurado)
values (_secuencia,a_no_remesa,_renglon,_secuencia_email,_cod_cliente);}

return 0,'';

end procedure
  



