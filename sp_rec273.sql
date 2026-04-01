--Procedimiento para sacar info. de reclamos que no se ha completado el pago del deducible por los asegurados.
--Armando Moreno M. 10/07/2017

drop procedure sp_rec273;
create procedure sp_rec273(a_compania char(3), a_fecha1 date, a_fecha2 date, a_ramo char(255) )
returning char(18),char(10),date,date,varchar(60),char(30),char(10),varchar(60),char(30),char(10),varchar(60),decimal(16,2),decimal(16,2),decimal(16,2),char(10),char(20),char(50),char(50),smallint,char(10),char(5);

define _no_requis		char(10);
define _cod_cliente		char(10);
define _cod_cliente_rec		char(10);
define _nom_tipopago	char(50);
define _monto			dec(16,2);
define _cod_tipopago    char(3);
define _periodo_pago    smallint;
define _cod_banco       char(3);
define _cod_chequera    char(3);
define _a_nombre_de		char(100);
define _nom_recla		char(100);
define _nom_aseg		char(100);
define _firma1			char(8);
define _firma2			char(8);
define _cod_asegurado,_no_recupero	char(10);
define _cod_reclamante	char(10);
define _no_reclamo		char(10);
define _monto_tran,_monto_incurrido		dec(16,2);
define _fecha,_fecha_siniestro,_fecha_reclamo			date;
define _transaccion		char(10);
define _reclamo			char(18);
define _pagado		    smallint;
define _generar_cheque  smallint;
define _anular_nt		char(10);
define _cod_proveedor   char(10);
define _n_proveedor		char(100);
define _grupo    		char(20);
define _desc_ramo		char(100);
DEFINE _no_poliza       CHAR(10);
define _periodo 		char(7);
DEFINE _cod_grupo       CHAR(5);
DEFINE _cod_ramo        CHAR(3);
DEFINE _cod_subramo     CHAR(3);
DEFINE _doc_poliza      CHAR(20);
DEFINE _cod_sucursal    CHAR(3);
DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(01);
DEFINE _cantidad        smallint;
DEFINE _no_tramite,_no_tranrec      char(10);
DEFINE _no_orden_compra char(10);
define _estatus_aud,_cnt,_cnt1     smallint;
define _periodo1		char(7);
define _periodo2		char(7);
define _tel1,_tel_corr,_cod_tercero      char(10);
define _email_aseg,_email_corr     char(30);
define _deducible,_deducible_pagado,_monto_desc_ded dec(16,2);
define _cod_agente                  char(5);
define _n_corredor		varchar(60);
define _no_documento    char(20);
define _no_unidad       char(5);
define _n_marca,_n_modelo char(50);
define _ano_auto          smallint;
define _placa             char(10);
define _no_motor          char(30);

create temp table tmp_reclamos(
       no_reclamo    		char(10),
	   cod_cliente   		char(10),
	   deducible     		dec(16,2)  default 0,
	   deducible_pagado		dec(16,2)  default 0,
	   monto_incurrido      dec(16,2)  default 0,
	   monto_desc_ded 		dec(16,2)  default 0);
	   
create index idx_tmp_reclamos1 on tmp_reclamos(no_reclamo);

SET ISOLATION TO DIRTY READ;
-- Procesos v_filtros
LET v_filtros ="";

--Filtro por Ramo
IF a_ramo <> "*" THEN
 LET v_filtros = TRIM(v_filtros) ||"Ramo "||TRIM(a_ramo);
 LET _tipo = sp_sis04(a_ramo);  -- Separa los valores del String
END IF

let _periodo1 = sp_sis39(a_fecha1);
let _periodo2 = sp_sis39(a_fecha2);

foreach
	select cod_tipopago,
		   transaccion,
		   fecha,
		   monto,
		   no_reclamo,
		   no_requis,
		   cod_proveedor,
		   anular_nt,
		   pagado,
		   generar_cheque,
		   cod_cliente,
		   no_tranrec
	  into _cod_tipopago,
		   _transaccion,
		   _fecha,
		   _monto_tran,
		   _no_reclamo,
		   _no_requis,
		   _cod_proveedor,
		   _anular_nt,
		   _pagado,
		   _generar_cheque,
		   _cod_cliente_rec,
		   _no_tranrec
	  from rectrmae
	 where cod_compania = a_compania
	   and actualizado  = 1
	   and cod_tipotran = "004"
	   and cod_tipopago = "004"	--pago a tercero
	   and periodo      >= _periodo1
	   and periodo      <= _periodo2
	   and anular_nt is null
   
	 select cod_asegurado,
			cod_reclamante,
			numrecla,
			no_poliza,
			periodo,
			no_tramite,
			estatus_audiencia
	   into _cod_asegurado,
			_cod_reclamante,
			_reclamo,
			_no_poliza,
			_periodo,
			_no_tramite,
			_estatus_aud
	   from recrcmae
	  where no_reclamo = _no_reclamo;

	if _estatus_aud in(0,8) then	--solo perdido, fut responsable
	else
		continue foreach;
	end if

	select cod_ramo,
		   cod_grupo,
		   cod_subramo,
		   cod_contratante,
		   no_documento,
		   cod_sucursal
	  into _cod_ramo,
		   _cod_grupo,
		   _cod_subramo,
		   _cod_cliente,
		   _doc_poliza,
		   _cod_sucursal
	  from emipomae
	 where no_poliza = _no_poliza;

	IF a_ramo <> "*" THEN   

		SELECT count(*)
		  INTO _cantidad
		  FROM tmp_codigos
		 WHERE trim(codigo) IN (trim(_cod_ramo));

		 if _tipo <> "E" then
			if _cantidad = 0 then
				CONTINUE FOREACH;
			end if
		 else
			if _cantidad = 1 then
				CONTINUE FOREACH;
			end if
		 end if
	END IF
	
 if _cod_subramo in('005','002','006','012','004') then
 else
	continue foreach;
 end if
 
 select count(*)
   into _cnt
   from rectrcob
  where no_tranrec = _no_tranrec
    and cod_cobertura in('01022','00113','00671','01304')
	and monto <> 0;

if _cnt is null then
	let _cnt = 0;
end if
let _monto_incurrido = 0.00;
if _cnt > 0 then
	foreach
		select monto 
		  into _monto_incurrido
		  from rectrcob
		 where no_tranrec = _no_tranrec
		   and cod_cobertura in('01022','00113','00671','01304')
	       and monto <> 0
		exit foreach;   
		
	end foreach
	
    select count(*)
	  into _cnt1
	  from tmp_reclamos
	 where no_reclamo = _no_reclamo;
    if _cnt1 is null then
		let _cnt1 = 0;
	end if
	let _monto_desc_ded = 0;
	select sum(monto)
	  into _monto_desc_ded
	  from rectrcon
	 where no_tranrec = _no_tranrec
	   and cod_concepto = '006';
	   if _monto_desc_ded is null then
			let _monto_desc_ded = 0;
	   end if
	if _cnt1 = 0 then
		insert into tmp_reclamos(no_reclamo,cod_cliente,deducible,deducible_pagado,monto_incurrido,monto_desc_ded)
		values(_no_reclamo,_cod_cliente_rec,0,0,_monto_incurrido,_monto_desc_ded);
	else
	    update tmp_reclamos
		   set monto_desc_ded = monto_desc_ded + _monto_desc_ded
		 where no_reclamo = _no_reclamo;  
		continue foreach;
	end if
else
	continue foreach;
end if
 
end foreach

let _deducible = 0.00;
let _deducible_pagado = 0.00;
foreach

	select no_reclamo, monto_desc_ded
	  into _no_reclamo, _monto_desc_ded
	  from tmp_reclamos
	 order by no_reclamo 

	foreach
		select a.deducible, a.deducible_pagado
		  into _deducible, _deducible_pagado
		  from recrccob a, prdcober b
		 where a.cod_cobertura = b.cod_cobertura
		   and a.no_reclamo = _no_reclamo
		   and b.nombre like '%PROPIEDAD AJENA%'
	end foreach
	
	if _deducible is null then
		let _deducible = 0.00;
	end if
	
	if _deducible_pagado is null then
		let _deducible_pagado = 0.00;
	end if
	let _deducible_pagado = _deducible_pagado + _monto_desc_ded;
	let _deducible_pagado = ABS(_deducible_pagado);
	if _deducible > 0.00 then
		if _deducible_pagado >= _deducible then
			continue foreach;
		end if	
    end if
	update tmp_reclamos
	   set deducible        = _deducible,
	       deducible_pagado = _deducible_pagado
	 where no_reclamo       = _no_reclamo;
	 
end foreach
--*******************
 foreach
	select no_reclamo, cod_cliente,monto_incurrido,deducible,deducible_pagado
	  into _no_reclamo, _cod_tercero,_monto_incurrido,_deducible,_deducible_pagado
	  from tmp_reclamos
	 order by no_reclamo
	 
    if _deducible = 0 and _deducible_pagado = 0 then
		continue foreach;
	end if	
	 select cod_asegurado,
			cod_reclamante,
			numrecla,
			no_poliza,
			fecha_siniestro,
			no_tramite,
			estatus_audiencia,
			no_tramite,
			fecha_reclamo,
			no_documento,
			no_unidad
	   into _cod_asegurado,
			_cod_reclamante,
			_reclamo,
			_no_poliza,
			_fecha_siniestro,
			_no_tramite,
			_estatus_aud,
			_no_tramite,
			_fecha_reclamo,
			_no_documento,
			_no_unidad
	   from recrcmae
	  where no_reclamo = _no_reclamo;
	  
	  let _no_recupero = sp_rec176(_reclamo);
	  
	  foreach
		select cod_agente
		  into _cod_agente
		  from emipoagt
		 where no_poliza = _no_poliza
		exit foreach; 
	  end foreach

let _no_motor = null;
 select no_motor
   into _no_motor
   from emiauto
  where no_poliza = _no_poliza
    and no_unidad = _no_unidad;

if _no_motor is null then
	foreach
		select no_motor
		   into _no_motor
		   from endmoaut
		  where no_poliza = _no_poliza
			and no_unidad = _no_unidad
			exit foreach;
	end foreach
end if

select a.nombre,c.ano_auto,c.placa
   into _n_marca,_ano_auto,_placa
   from emimarca a, emivehic c
  where a.cod_marca = c.cod_marca
    and c.no_motor = _no_motor;

 select a.nombre
   into _n_modelo
   from emimodel a, emivehic c
  where a.cod_modelo = c.cod_modelo
    and c.no_motor = _no_motor;
	
 select nombre,e_mail,telefono1
   into _n_corredor,_email_corr,_tel_corr
   from agtagent
  where cod_agente = _cod_agente;
  
 select nombre
   into _desc_ramo
   from prdramo
  where cod_ramo = _cod_ramo;

 select nombre
   into _nom_tipopago
   from rectipag
  where cod_tipopago = _cod_tipopago;

 select nombre
   into _nom_recla
   from cliclien
  where cod_cliente = _cod_tercero;
  
 select nombre,e_mail,telefono1
   into _nom_aseg,_email_aseg,_tel1
   from cliclien
  where cod_cliente = _cod_asegurado;

 return _reclamo,
  	    _no_tramite,
   	    _fecha_siniestro,
	    _fecha_reclamo,
		_nom_aseg,
		_email_aseg,
		_tel1,
		_n_corredor,
		_email_corr,
		_tel_corr,
		_nom_recla,
		_monto_incurrido,
		_deducible,
		_deducible_pagado,
	    _no_recupero,
		_no_documento,
		_n_marca,
		_n_modelo,
		_ano_auto,
		_placa,
		_no_unidad
	    with resume;
end foreach
DROP TABLE tmp_reclamos;
IF a_ramo <> "*" THEN
	DROP TABLE tmp_codigos;
END IF
end procedure  	