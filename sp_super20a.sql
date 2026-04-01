--Procedimiento para sacar info. de reclamos que no se ha completado el pago del deducible por los asegurados.
--Armando Moreno M. 10/07/2017

drop procedure sp_super20a;
create procedure sp_super20a(a_compania char(3), a_fecha1 date, a_fecha2 date, a_ramo char(255))
returning char(10),char(18),date,date,varchar(100),decimal(16,2),decimal(16,2),char(20),char(5),char(1),char(50),char(30),date,char(50),decimal(16,2),
          char(10),varchar(20),char(15),char(50),char(40),char(1),char(100),char(1),date,char(15),char(15),char(15);

		  
		  
define _no_requis		char(10);
define _cod_cliente		char(10);
define _cod_cliente_rec		char(10);
define _nom_tipopago,n_ajustador	char(50);
define _monto			dec(16,2);
define _cod_tipopago,_cod_ajustador    char(3);
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
define _fecha,_fecha_siniestro,_fecha_reclamo,_fecha_pag_ded,_fecha_nacimiento  date;
define _transaccion		char(10);
define _reclamo			char(18);
define _pagado		    smallint;
define _anular_nt		char(10);
define _cod_proveedor   char(10);
define _n_proveedor,_n_asegurado		char(100);
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
define _email_aseg,_email_corr,_n_evento     char(30);
define _deducible,_deducible_pagado,_monto_desc_ded dec(16,2);
define _cod_agente                  char(5);
define _n_corredor		varchar(60);
define _no_documento    char(20);
define _no_unidad       char(5);
define _n_marca,_n_modelo,_n_cobertura,_n_subramo,_n_tipoveh char(50);
define _ano_auto          smallint;
define _placa             char(10);
define _no_motor          char(30);
define _estatus_reclamo   char(1);
define _cod_evento,_cod_tipoveh        char(3);
define _n_est_aud         char(15);
define _parte_poli        char(10);
define _no_resol          varchar(20);
define _sexo,_uso_auto    char(1);
define _cnt_chofer        smallint;
define _cober_aep,_cober,_cober_ap char(15);

create temp table tmp_reclamos(
       no_reclamo    		char(10),
	   cod_cliente   		char(10),
	   deducible     		dec(16,2)  default 0,
	   deducible_pagado		dec(16,2)  default 0,
	   monto_incurrido      dec(16,2)  default 0,
	   monto_desc_ded 		dec(16,2)  default 0,
	   n_subramo            char(50));
	   
create index idx_tmp_reclamos1 on tmp_reclamos(no_reclamo);

SET ISOLATION TO DIRTY READ;
-- Procesos v_filtros
LET v_filtros ="";
let _n_subramo = "";

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
	   --and numrecla in('02-0714-02074-01','02-1014-02970-01')
   
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
	select nombre into _n_subramo from prdsubra
	where cod_ramo    = _cod_ramo
	  and cod_subramo = _cod_subramo;
	
 {if _cod_subramo in('005','002','006','012','004') then
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
}
let _monto_incurrido = 0.00;
--if _cnt > 0 then
	{foreach
		select monto 
		  into _monto_incurrido
		  from rectrcob
		 where no_tranrec = _no_tranrec
		   and cod_cobertura in('01022','00113','00671','01304')
	       and monto <> 0
		exit foreach;   
		
	end foreach}
	
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
		insert into tmp_reclamos(no_reclamo,cod_cliente,deducible,deducible_pagado,monto_incurrido,monto_desc_ded,n_subramo)
		values(_no_reclamo,_cod_cliente_rec,0,0,_monto_incurrido,_monto_desc_ded,_n_subramo);
	else
	    update tmp_reclamos
		   set monto_desc_ded = monto_desc_ded + _monto_desc_ded
		 where no_reclamo = _no_reclamo;  
		continue foreach;
	end if
{else
	continue foreach;
end if}
 
end foreach

let _deducible = 0.00;
let _deducible_pagado = 0.00;
{foreach

	select no_reclamo, monto_desc_ded
	  into _no_reclamo, _monto_desc_ded
	  from tmp_reclamos
	 order by no_reclamo 

	foreach
		select a.deducible, a.deducible_pagado, b.nombre
		  into _deducible, _deducible_pagado, _n_cobertura
		  from recrccob a, prdcober b
		 where a.cod_cobertura = b.cod_cobertura
		   and a.no_reclamo = _no_reclamo

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
	 
end foreach}
--*******************
 foreach
	select no_reclamo, cod_cliente,monto_incurrido,deducible,deducible_pagado,monto_desc_ded,n_subramo
	  into _no_reclamo, _cod_tercero,_monto_incurrido,_deducible,_deducible_pagado,_monto_desc_ded,_n_subramo
	  from tmp_reclamos
	 order by no_reclamo
	 
    {if _deducible = 0 and _deducible_pagado = 0 then
		continue foreach;
	end if	}
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
			no_unidad,
			estatus_reclamo,
			ajust_interno,
			cod_evento,
			parte_policivo,
			no_resolucion
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
			_no_unidad,
			_estatus_reclamo,
			_cod_ajustador,
			_cod_evento,
			_parte_poli,
			_no_resol
	   from recrcmae
	  where no_reclamo = _no_reclamo;
	  
	  let _fecha_pag_ded = null;
	  select max(fecha)
	    into _fecha_pag_ded
		from cobredet
	   where no_reclamo = _no_reclamo
	     and actualizado = 1
	     and tipo_mov   = 'D';
	   

 let _no_motor = null;
 select no_motor,cod_tipoveh,uso_auto
   into _no_motor,_cod_tipoveh,_uso_auto
   from emiauto
  where no_poliza = _no_poliza
    and no_unidad = _no_unidad;

select nombre into _n_tipoveh from emitiveh
where cod_tipoveh = _cod_tipoveh;

let _cnt_chofer = 0;

select count(*)
  into _cnt_chofer
  from emipocob
 where no_poliza = _no_poliza
   and no_unidad = _no_unidad
   and cod_cobertura in('01481','01536');
if _cnt_chofer is null then
	let _cnt_chofer = 0;
end if
if _cnt_chofer = 0 then
	select count(*)
	  into _cnt_chofer
	  from endedcob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura in('01481','01536');
	if _cnt_chofer is null then
		let _cnt_chofer = 0;
	end if
end if
LET _cober = "";
if _cnt_chofer > 0 then
	let _cober = 'CHOFER';
end if

select count(*)
  into _cnt_chofer
  from emipocob
 where no_poliza = _no_poliza
   and no_unidad = _no_unidad
   and cod_cobertura in('00104','01301');
if _cnt_chofer is null then
	let _cnt_chofer = 0;
end if
if _cnt_chofer = 0 then
	select count(*)
	  into _cnt_chofer
	  from endedcob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura in('00104','01301');
	if _cnt_chofer is null then
		let _cnt_chofer = 0;
	end if
end if
LET _cober_ap = "";
if _cnt_chofer > 0 then
	let _cober_ap = 'ANCON PLUS';
end if

select count(*)
  into _cnt_chofer
  from emipocob
 where no_poliza = _no_poliza
   and no_unidad = _no_unidad
   and cod_cobertura in('01535');
if _cnt_chofer is null then
	let _cnt_chofer = 0;
end if
if _cnt_chofer = 0 then
	select count(*)
	  into _cnt_chofer
	  from endedcob
	 where no_poliza = _no_poliza
	   and no_unidad = _no_unidad
	   and cod_cobertura in('01535');
	if _cnt_chofer is null then
		let _cnt_chofer = 0;
	end if
end if
LET _cober_aep = "";
if _cnt_chofer > 0 then
	let _cober_aep = 'ANCON EXT. PLUS';
end if

if _no_motor is null then
	foreach
		select no_motor,uso_auto,cod_tipoveh
		   into _no_motor,_uso_auto,_cod_tipoveh
		   from endmoaut
		  where no_poliza = _no_poliza
			and no_unidad = _no_unidad
			exit foreach;
	end foreach
end if
select nombre
  into _n_tipoveh
  from emitiveh
 where cod_tipoveh = _cod_tipoveh;

 select nombre
   into _nom_recla
   from cliclien
  where cod_cliente = _cod_reclamante;
 
 select nombre,fecha_aniversario,sexo
   into _n_asegurado,_fecha_nacimiento,_sexo
   from cliclien
  where cod_cliente = _cod_asegurado;
  
  let _n_est_aud = '';
if _estatus_aud = 1 then
	let _n_est_aud = 'Ganado';
elif _estatus_aud = 0 then
	let _n_est_aud = 'Perdido';
elif _estatus_aud = 2 then
	let _n_est_aud = 'Por definir';
elif _estatus_aud = 3 then
	let _n_est_aud = 'Proceso Penal';
elif _estatus_aud = 4 then
	let _n_est_aud = 'Proceso Civil';
elif _estatus_aud = 5 then
	let _n_est_aud = 'Apelación';
elif _estatus_aud = 6 then
	let _n_est_aud = 'Resuelto';
elif _estatus_aud = 7 then
	let _n_est_aud = 'FUT-Ganado';
elif _estatus_aud = 8 then
	let _n_est_aud = 'FUT-Responsable';
end if
  
select nombre into n_ajustador from recajust where cod_ajustador = _cod_ajustador;  
select nombre into _n_evento from recevent where cod_evento = _cod_evento;
		foreach
				select a.deducible, a.deducible_pagado, b.nombre
				  into _deducible, _deducible_pagado, _n_cobertura
				  from recrccob a, prdcober b
				 where a.cod_cobertura = b.cod_cobertura
				   and a.no_reclamo = _no_reclamo
				   
				let _deducible_pagado = _deducible_pagado + _monto_desc_ded;
				let _deducible_pagado = ABS(_deducible_pagado);
				if _deducible is null then
					let _deducible = 0.00;
				end if
				if _deducible_pagado is null then
					let _deducible_pagado = 0.00;
				end if
				if _deducible = 0 and _deducible_pagado = 0 then
					continue foreach;
				end if
				return _no_reclamo,
				       _reclamo,
					   _fecha_siniestro,
					   _fecha_reclamo,
					   _nom_recla,
					   _deducible,
						_deducible_pagado,
						_no_documento,
						_no_unidad,
						_estatus_reclamo,
						n_ajustador,
						_n_evento,
						_fecha_pag_ded,
						_n_cobertura,
						_monto_desc_ded,
						_parte_poli,
						_no_resol,
						_n_est_aud,
						_n_subramo,
						_n_tipoveh,
						_uso_auto,
						_n_asegurado,
						_sexo,
						_fecha_nacimiento,
						_cober,
						_cober_ap,
						_cober_aep
						with resume;
				let _monto_desc_ded = 0.00;						
		end foreach		
end foreach
   
IF a_ramo <> "*" THEN
	DROP TABLE tmp_codigos;
END IF
drop table tmp_reclamos;
end procedure  	