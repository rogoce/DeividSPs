--ESTE DEBE SER EL PROCEDURE QUE SE DEBE USAR PARA LA HOJA DE AUDITO EN DEIVID GESTION, ARMANDO 20/03/2020


DROP PROCEDURE sp_rec83_dg;
create procedure sp_rec83_dg()
returning char(20),
          date,
          date,
		  date,
		  char(100),
		  char(10),	
		  dec(16,2),
  		  dec(16,2),			
		  dec(16,2),			
		  dec(16,2),			
		  dec(16,2),			
		  dec(16,2),			
		  dec(16,2),
		  dec(16,2),
		  char(100),
		  varchar(50),
		  char(50),
		  char(50),
  		  char(100),
		  char(5),
		  char(100),
		  char(100),
		  smallint,
		  varchar(50);

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
define _suma_asegurada, _stop_loss dec(16,2);
define _bene1,_bene2,_bene3, _bene4 varchar(65);

define _cod_proveedor	char(10);
define _nombre_cia,n_cobertura,n_tipo 		char(50);
define _no_unidad		char(10);
define _cod_contratante	char(10);
define _nombre_cont		char(100);
define _no_poliza		char(10);
define _no_endoso,_cod_cobertura		char(5);
define _vigencia_inic	date;
define _vigencia_final	date;
define _cod_tipotran,_cod_tipopago    char(3);
define _cod_tipo   char(3);
define _fecha_gasto		date;
define _periodo			char(7);
define _dependencia		char(50);
define _cod_parentesco  char(3);
define _no_tranrec		char(10);
define _nombre_icd,_nombre_contratante		char(100);
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
define _n_prod,n_tipo_pago		varchar(50);
define _cod_asignacion  char(10);

define _ded_fuera		decimal(16,2);
define _ded_local_monto	decimal(16,2);
define _ded_fuera_monto	decimal(16,2);
define _ded_acum_l,_ded_acum_ext decimal(16,2);
define _tipo_acum_deduc,_exterior    smallint;
define _vig_ini_i, _vig_fin_i,_fecha_reclamo date;
define _cod_producto    char(5);

{if a_no_reclamo = '18-0519-02718-01' then
	set debug file to "sp_rec83.trc";
	trace on;
end if}

set isolation to dirty read;

let _n_prod = "";
let _bene1 = "";
let _bene2 = "";
let _bene3 = "";
let _bene4 = "";
let _suma_asegurada = 0.00;
let _stop_loss      = 0;

select cod_tipotran
  into _cod_tipotran
  from rectitra
 where tipo_transaccion = 4;	--Pago del Reclamo

--let _nombre_cia  = sp_sis01(a_compania); 
--let a_no_reclamo = trim(a_no_reclamo);
		
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
		cod_asignacion,
		fecha_reclamo
   into	_numrecla,
		_cod_icd,
        _fecha_siniestro,
		_cod_reclamante,
		_cod_contratante,
		_no_reclamo,
		_no_unidad,
		_no_poliza,
		_periodo,
		_cod_asignacion,
		_fecha_reclamo
   from recrcmae
  where	no_documento = '1819-99900-01'
    and periodo >= '2023-08'
	and periodo <= '2023-10'
    and actualizado  = 1

	 
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

	SELECT plan, a.suma_asegurada ,deducible_local, coaseguro_hasta , beneficio1, beneficio2, beneficio3, beneficio4
	  into _n_prod,_suma_asegurada, _ded_local ,_stop_loss, _bene1,_bene2,_bene3, _bene4
	  FROM emipouni a, prdprod b
	 where a.cod_producto = b.cod_producto
	   and no_poliza      = _no_poliza
	   and no_unidad      = _no_unidad;

	select vigencia_inic,
	       vigencia_final,
		   no_documento
	  into _vigencia_inic,
	       _vigencia_final,
		   _no_documento
	  from emipomae
	 where no_poliza = _no_poliza;

if _tipo_acum_deduc = 2 then  -- aÃ±o poliza
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
	   and cod_tipotran = _cod_tipotran;
		

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

	select nombre
	  into _nombre_contratante
	  from cliclien
	 where cod_cliente = '114979';

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

		 select min(fecha_factura),
		        max(fecha_factura)
		   into	v_fecha_desde,
				v_fecha_hasta
		   from rectrmae
		  where no_reclamo    = _no_reclamo
		    and actualizado   = 1
			and cod_tipotran = _cod_tipotran;

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
			no_factura,
			cod_tipopago
	   into	_cod_proveedor,
			_fecha_gasto,
			_cod_cpt,
			_no_tranrec,
			_fecha_factura,
			_no_requis,
			_no_fac,
			_cod_tipopago
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and actualizado  = 1
		and cod_tipotran = _cod_tipotran

		if _no_fac is null then
			let _no_fac = "";
		end if
		if _fecha_factura is null then
			continue foreach;
		end if

		
		if _cod_cpt is null then
			let _cod_cpt = "";
		end if

		select nombre
		  into _nombre_cpt
		  from reccpt
		 where cod_cpt = _cod_cpt;
		
		select nombre into n_tipo_pago from rectipag
		where cod_tipopago = _cod_tipopago;		

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
				ahorro,
				cod_tipo,
				cod_cobertura
		   into	_gasto_fact,
		        _gasto_eleg,
				_a_deducible,
				_co_pago,
				_coaseguro,
				_pago_prov,
				_gastos_no_cub,
				_cod_no_cubierto,
				_ahorro,
				_cod_tipo,
				_cod_cobertura
		   from rectrcob
		  where no_tranrec = _no_tranrec
		  
          select nombre into n_cobertura from prdcober
  		   where cod_cobertura = _cod_cobertura;

		  
		  select nombre,exterior into n_tipo,_exterior from prdticob
		  where cod_tipo = _cod_tipo;

			return _numrecla,
			       _fecha_reclamo,
			       _fecha_siniestro,
				   _fecha_gasto,
				   _nombre_icd,
				   _cod_cpt,
				   _gasto_fact,
				   _gastos_no_cub,
				   _gasto_eleg,
				   _a_deducible,
				   _ahorro,			   -- 11
				   _co_pago,		   -- 12	
				   _coaseguro,		   -- 13
				   _pago_prov,		   -- 14
				   _nombre_prov,	   -- 15	
				   n_tipo_pago,	       -- 16
				   n_cobertura,
				   n_tipo,
				   _nombre_contratante,
				   _no_unidad,
				   _nombre_recla,
				   _nombre_cont,
				   _exterior,
				   _n_prod
				   with resume;

			let _a_deducible2 = 0;
		end foreach
	end foreach
end foreach
end procedure                                                                                                                                                                               