-- Hoja de Auditoria para Reclamos de Salud (Para Pago de Reclamos)

-- Creado    : 20/04/2004 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 08/09/2010 - Autor: Roman Gordon
-- 
-- SIS v.2.0 - d_recl_sp_rec83_dw1 - DEIVID, S.A.

drop procedure sp_rec83;

create procedure sp_rec83(
a_compania		char(3),
a_no_reclamo	char(20),
a_todos			smallint,
a_fecha_desde	date,
a_fecha_hasta	date,
a_tran			char(10) default '*'
)

returning char(20),				 
          date,					
		  char(10),				
		  char(10),				
		  dec(16,2),			
		  dec(16,2),			
		  dec(16,2),			
		  dec(16,2),			
		  dec(16,2),			
		  dec(16,2),			
		  char(100),			
		  dec(16,2),
		  char(100),			
		  char(100),			
		  char(10),				
		  char(10),				
		  char(50),				
		  char(10),				
		  char(100),			
		  date,					
		  date,					
		  char(7),				
		  char(50),
		  char(100),
		  char(100),
		  date,
		  char(20),
		  char(3),
		  date,
		  date,
		  char(10),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  varchar(50),
		  char(10),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  dec(16,2),
		  integer,
		  integer,
		  smallint,
		  char(5);

define _numrecla		char(20);
define _no_documento	char(20);
define _fecha_siniestro	date;
define _cod_icd			char(10);
define _cod_cpt			char(10);
define _no_reclamo		char(10);
define _cod_reclamante	char(10);
define _cod_asegurado	char(10);
define _nombre_recla	char(100);
define _nombre_aseg		char(100);

define _gasto_fact		dec(16,2);
define _gasto_eleg		dec(16,2);
define _a_deducible		dec(16,2);
define _co_pago			dec(16,2);
define _coaseguro		dec(16,2);
define _pago_prov		dec(16,2);
define _nombre_prov		char(100);
define _gastos_no_cub	dec(16,2);
define _ahorro          dec(16,2);

define _cod_proveedor	char(10);
define _nombre_cia 		char(50);
define _no_unidad		char(10);
define _cod_contratante	char(10);
define _nombre_cont		char(100);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _vigencia_inic	date;
define _vigencia_final	date;
define _cod_tipotran    char(3);
define _cod_tipotran2   char(3);
define _fecha_gasto		date;
define _periodo			char(7);
define _dependencia		char(50);
define _cod_parentesco  char(3);
define _no_tranrec		char(10);
define _nombre_icd		char(100);
define _nombre_cpt		char(100);
define _cod_no_cubierto	char(3);
define _fecha_factura	date;
define _fecha_desde		date;
define _fecha_hasta		date;
define v_fecha_desde	date;
define v_fecha_hasta	date;
define _no_requis       char(10);
define _no_fac	        char(10);
define _ded_local       dec(16,2);
define _ano             integer;
define _ano2            integer;
define _a_deducible2	dec(16,2);
define _cod_agente      char(5);
define _nom_agente		varchar(50);
define _cod_asignacion  char(10);
define _cod_entrada		char(10);

define _ded_fuera		decimal(16,2);
define _ded_local_monto	decimal(16,2);
define _ded_fuera_monto	decimal(16,2);
define _ded_acum_l,_ded_acum_ext decimal(16,2);
define _tipo_acum_deduc    smallint;
define _vig_ini_i, _vig_fin_i date;
define _cod_producto    char(5);


{if a_no_reclamo = '18-0919-13297-01' then
	set debug file to "sp_rec83.trc";
	trace on;
end if }

set isolation to dirty read;

select cod_tipotran
  into _cod_tipotran
  from rectitra
 where tipo_transaccion = 4;	--Pago del Reclamo

select cod_tipotran
  into _cod_tipotran2
  from rectitra
 where tipo_transaccion = 13;	--Declinacion del reclamo

let _nombre_cia  = sp_sis01(a_compania); 
let a_no_reclamo = trim(a_no_reclamo);
		
foreach

 select	numrecla,
		cod_icd,
        fecha_siniestro,
		cod_reclamante,
		cod_asegurado,
		no_reclamo,
		no_unidad,
		no_poliza,
		periodo,
		cod_asignacion
   into	_numrecla,
		_cod_icd,
        _fecha_siniestro,
		_cod_reclamante,
		_cod_contratante,
		_no_reclamo,
		_no_unidad,
		_no_poliza,
		_periodo,
		_cod_asignacion
   from recrcmae
  where	numrecla = a_no_reclamo


  	let _cod_asignacion = null;
 	let _cod_agente = "";
	let _cod_entrada = "";

	if a_tran <> '*' then
		select fecha_factura
		 into _fecha_siniestro
		 from rectrmae
		 where no_reclamo = _no_reclamo
		  and transaccion = a_tran;
	end if

	select cod_asignacion
	   into _cod_asignacion
	   from recrcmae
	  where numrecla = a_no_reclamo;


	if _cod_asignacion is not null then
		select cod_entrada
		  into _cod_entrada
		  from atcdocde
		 where cod_asignacion = _cod_asignacion;
	end if


	FOREACH WITH HOLD
	  SELECT cod_agente
	    INTO _cod_agente
	    FROM emipoagt
	   WHERE no_poliza = _no_poliza
	   EXIT FOREACH;
	END FOREACH

	
	SELECT nombre
	  INTO _nom_agente
	  FROM agtagent
	 WHERE cod_agente =_cod_agente;
	 
	let _cod_producto = null;

	let _cod_producto =  sp_rec282(_no_poliza, _no_unidad, _fecha_siniestro);
	
	if _cod_producto is not null and trim(_cod_producto) <> "" then
		SELECT p.deducible_local,p.deducible_fuera,p.tipo_acum_deduc
		  into _ded_local,_ded_fuera,_tipo_acum_deduc
		  FROM prdprod p
		 WHERE p.cod_producto = _cod_producto;	
    else
		SELECT p.deducible_local,p.deducible_fuera,p.tipo_acum_deduc
		  into _ded_local,_ded_fuera,_tipo_acum_deduc
		  FROM prdprod p, emipouni a
		 WHERE a.cod_producto = p.cod_producto 
		   AND no_poliza      = _no_poliza
		   AND no_unidad      = _no_unidad;
    end if

	if _ded_fuera is null then
		let _ded_fuera = 0;
	end if

	if _ded_local is null then
		let _ded_local = 0;
	end if

	select vigencia_inic,
	       vigencia_final,
		   no_documento
	  into _vigencia_inic,
	       _vigencia_final,
		   _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

if _tipo_acum_deduc = 2 then  -- año poliza
	call sp_sis21g(_vigencia_inic,_fecha_siniestro) returning _vig_ini_i, _vig_fin_i;
	select sum(a.a_deducible)
	  into _a_deducible2
	  from recrcmae r, rectrmae t, rectrcob a
	 where r.no_reclamo   = t.no_reclamo
	   and t.no_tranrec   = a.no_tranrec
	   and r.no_documento = _no_documento
	   and r.actualizado  = 1
	   and t.fecha_factura >= _vig_ini_i
	   and t.fecha_factura <= _vig_fin_i
	   and r.cod_reclamante = _cod_reclamante;	
	let _ano = year(_vig_ini_i);
	let _ano2 = year(_vig_fin_i);
else
	select year(max(fecha_factura))
	  into	_ano
	  from rectrmae
	 where no_reclamo    = _no_reclamo
	   and actualizado   = 1
	   and (cod_tipotran = _cod_tipotran
		or cod_tipotran  = _cod_tipotran2);

	select sum(a.a_deducible)
	  into _a_deducible2
	  from recrcmae r, rectrmae t, rectrcob a
	 where r.no_reclamo   = t.no_reclamo
	   and t.no_tranrec   = a.no_tranrec
	   and r.no_documento = _no_documento
	   and r.actualizado  = 1
	   and year(t.fecha_factura) = _ano
	   and r.cod_reclamante      = _cod_reclamante;
	   
	let _ano2 = _ano + 1;   
end if
	select nombre
	  into _nombre_icd
	  from recicd
	 where cod_icd = _cod_icd;

	if _cod_icd is null then
		let _cod_icd    = "";
		let _nombre_icd = "";
	end if

	select nombre
	  into _nombre_cont
	  from cliclien
	 where cod_cliente = _cod_contratante;

	select nombre
	  into _nombre_recla
	  from cliclien
	 where cod_cliente = _cod_reclamante;

	let _cod_asegurado = null;
		
	foreach
	 select cod_cliente,
	        no_endoso
	   into _cod_asegurado,
	        _no_endoso  
	   from endeduni
	  where no_poliza = _no_poliza
	    and no_unidad = _no_unidad
	  order by no_endoso desc
	    	exit foreach;
	end foreach  

	if _cod_asegurado is null then
		let _cod_asegurado = _cod_reclamante;
	end if

	select nombre
	  into _nombre_aseg
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	-- Descripcion de las Dependencias

	if _cod_asegurado = _cod_reclamante then
	
		let _dependencia = "ASEGURADO PRINCIPAL";
	
	else

		let _dependencia = null;

		select cod_parentesco
		  into _cod_parentesco
		  from emidepen
		 where no_poliza   = _no_poliza
		   and no_unidad   = _no_unidad
		   and cod_cliente = _cod_reclamante;

		select nombre
		  into _dependencia
		  from emiparen
		 where cod_parentesco = _cod_parentesco;

		if _dependencia is null then
			let _dependencia = "";
		end if

			
	end if		

	-- Transacciones de Reclamos

	if a_todos = 0 then		--por fecha

		let v_fecha_desde = a_fecha_desde;
		let v_fecha_hasta = a_fecha_hasta;
		let _fecha_desde  = a_fecha_desde;
		let _fecha_hasta  = a_fecha_hasta;

--		let v_fecha_desde = mdy(a_fecha_desde[4,5], a_fecha_desde[1,2], a_fecha_desde[7,10]);
--		let v_fecha_hasta = mdy(a_fecha_hasta[4,5], a_fecha_hasta[1,2], a_fecha_hasta[7,10]);
--		let _fecha_desde  = mdy(a_fecha_desde[4,5], a_fecha_desde[1,2], a_fecha_desde[7,10]);
--		let _fecha_hasta  = mdy(a_fecha_hasta[4,5], a_fecha_hasta[1,2], a_fecha_hasta[7,10]);

	else

		 select min(fecha_factura),
		        max(fecha_factura)
		   into	v_fecha_desde,
				v_fecha_hasta
		   from rectrmae
		  where no_reclamo    = _no_reclamo
		    and actualizado   = 1
			and (cod_tipotran = _cod_tipotran
			 or cod_tipotran  = _cod_tipotran2);

	end if
	----------------------------
	select monto_deducible,monto_deducible2
	  into _ded_local_monto,_ded_fuera_monto
	  from recacuan
	 where no_documento = _no_documento
       and ano          = _ano
       and cod_cliente  = _cod_reclamante;

	foreach
	 select cod_proveedor,
			fecha,
			cod_cpt,
			no_tranrec,
			fecha_factura,
			no_requis,
			no_factura
	   into	_cod_proveedor,
			_fecha_gasto,
			_cod_cpt,
			_no_tranrec,
			_fecha_factura,
			_no_requis,
			_no_fac
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and actualizado  = 1
		and transaccion  matches a_tran
		and (cod_tipotran = _cod_tipotran
		 or cod_tipotran  = _cod_tipotran2)

		if _no_fac is null then
			let _no_fac = "";
		end if
		if a_todos = 0 then
			if _fecha_factura is null then
				continue foreach;
			end if

			if _fecha_factura >= _fecha_desde and
			   _fecha_factura <= _fecha_hasta then
			else
				continue foreach;
			end if

		end if

		if _cod_cpt is null then
			let _cod_cpt = "";
		end if

		select nombre
		  into _nombre_cpt
		  from reccpt
		 where cod_cpt = _cod_cpt;

		select nombre
		  into _nombre_prov
		  from cliclien
		 where cod_cliente = _cod_proveedor;
		let _ahorro = 0.00;
		foreach
		 select	facturado,
		        elegible,
			   	a_deducible,
				co_pago,
				coaseguro,
				monto,
				monto_no_cubierto,
				cod_no_cubierto,
				ahorro
		   into	_gasto_fact,
		        _gasto_eleg,
				_a_deducible,
				_co_pago,
				_coaseguro,
				_pago_prov,
				_gastos_no_cub,
				_cod_no_cubierto,
				_ahorro
		   from rectrcob
		  where no_tranrec = _no_tranrec

			return _numrecla,		   -- 1
			       _fecha_siniestro,   -- 2
				   _cod_icd,		   -- 3
				   _cod_cpt,		   -- 4
				   _gasto_fact,		   -- 5		
				   _gasto_eleg,		   -- 6
				   _a_deducible,	   -- 7
				   _co_pago,		   -- 8	
				   _coaseguro,		   -- 9
				   _pago_prov,		   -- 10
				   _nombre_prov,	   -- 11	
				   _gastos_no_cub,	   -- 12
				   _nombre_cont,	   -- 13
				   _nombre_recla,	   -- 14
				   _cod_contratante,   -- 15
				   _cod_reclamante,	   -- 16
				   _nombre_cia,		   -- 17
				   _cod_asegurado,	   -- 18
				   _nombre_aseg,	   -- 19
				   _vigencia_inic,	   -- 20
				   _vigencia_final,	   -- 21
				   _periodo,		   -- 22
				   _dependencia,	   -- 23
				   _nombre_icd,		   -- 24	
				   _nombre_cpt,        --25
				   _fecha_factura,     --26
				   _no_documento,      --27
				   _cod_no_cubierto,   --28
				   v_fecha_desde,      --29
				   v_fecha_hasta,      --30
				   _no_requis,         --31
				   _no_fac,            --32
				   _ded_local,         --33
				   _a_deducible2,      --34
				   _nom_agente,        --35
				   _cod_entrada,       --36
				   _ded_fuera,         --37
				   _ded_local_monto,   --38
				   _ded_fuera_monto,   --39
				   _ahorro,             --40
				   _ano,
				   _ano2,
				   _tipo_acum_deduc,
				   _no_unidad
				   with resume;

			let _a_deducible2 = 0;
		end foreach
	end foreach
end foreach
end procedure;
