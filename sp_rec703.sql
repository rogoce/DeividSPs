-- Reporte para mostrar las polizas de CREDIREY con todos los Gastos medicos para Reclamos de Salud

-- Creado    : 31/07/2007 - Autor: Rub‚n Dar¡o Arnaez S nchez 



 drop procedure sp_rec703;

create procedure sp_rec703(a_compania char(3), a_no_documento char(20), a_cod_asegurado	char(10) default "*", a_cod_reclamante	char(10) default "*", a_no_reclamo char(20) default "*", a_periodo1 char(7), a_periodo2 char(7))
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
	  --  char(50),				
		  char(100),			
		  char(100),			
		  char(7),				
		  char(50),
		  char(50),
		  char(10),
		  char(50),
		  char(10);	

define _numrecla		char(20);
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

define _cod_proveedor	char(10);
define _nombre_cia 		char(50);
define _no_unidad		char(10);
define _cod_contratante	char(10);
define _nombre_cont		char(100);
define _no_poliza		char(10);
define _no_endoso		char(5);
define _vigencia_inic	date;
define _vigencia_final	date;
define _filtro_ano		char(100);
define _filtro_aseg		char(100);
define _filtro_recla	char(100);
define _cod_tipotran    char(3);
define _fecha_gasto		date;
define _periodo			char(7);
define _dependencia		char(50);
define _cod_parentesco  char(3);
define _no_tranrec		char(10);
define _cod_producto    char(5);
define a_fecha_desde 	date;
define a_fecha_hasta 	date;


define _nombre_icd		char(100);
define v_producto       char(50);
--define _nombre_cpt	char(100);

define _fecha_factura	date;

set isolation to dirty read;

select cod_tipotran
  into _cod_tipotran
  from rectitra
 where tipo_transaccion = 4;

let _nombre_cia  = sp_sis01(a_compania); 
let a_no_reclamo = trim(a_no_reclamo);

let a_fecha_desde = MDY(a_periodo1[6,7], 1, a_periodo1[1,4]);
let a_fecha_hasta = sp_sis36(a_periodo2);

		
foreach
 select	numrecla,
		cod_icd,
        fecha_siniestro,
		cod_reclamante,
--		cod_asegurado,
		no_reclamo,
		no_unidad,
		no_poliza,
		periodo
   into	_numrecla,
		_cod_icd,
        _fecha_siniestro,
		_cod_reclamante,
--		_cod_contratante,
		_no_reclamo,
		_no_unidad,
		_no_poliza,
		_periodo
   from recrcmae
  where	no_documento   = a_no_documento
    and actualizado    = 1
	and cod_reclamante matches a_cod_reclamante
	and numrecla       matches a_no_reclamo

	select vigencia_inic,
	       vigencia_final,
		   cod_contratante
	  into _vigencia_inic,
	       _vigencia_final,
		   _cod_contratante
	  from emipomae
	 where no_poliza = _no_poliza;

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

	-- Seleccionamos en codigo del producto
	 
	foreach
	 SELECT	cod_producto
	   INTO	_cod_producto
	   FROM	emipouni
	  where no_poliza = _no_poliza
	    and no_unidad = _no_unidad
	      	exit foreach;
	end foreach 

   	   
    	SELECT nombre
	      INTO v_producto
	      FROM prdprod
	     WHERE cod_producto = _cod_producto;

   	if _cod_asegurado is null then
		let _cod_asegurado = _cod_reclamante;
	end if

	if a_cod_asegurado <> "*" then 
		if a_cod_asegurado <> _cod_asegurado then
			continue foreach;
		end if
	end if		   	 

	select nombre
	  into _nombre_aseg
	  from cliclien
	 where cod_cliente = _cod_asegurado;

	-- Descripcion de Filtros

 --	if a_ano = "*" then
 --		let _filtro_ano = "Todos los Anios";
 --	else
 --		let _filtro_ano = a_ano;
 --	end if
	
	if a_cod_asegurado = "*" then
		let _filtro_aseg = "Todos los Asegurados";
	else
		let _filtro_aseg = _nombre_aseg;
	end if

	if a_cod_reclamante = "*" then
		let _filtro_recla = "Todos los Reclamantes";
	else
		let _filtro_aseg  = _nombre_aseg;
		let _filtro_recla = _nombre_recla;
	end if

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

	foreach
	 select cod_cliente,
			fecha,
			cod_cpt,
			no_tranrec,
			fecha_factura
	   into	_cod_proveedor,
			_fecha_gasto,
			_cod_cpt,
			_no_tranrec,
			_fecha_factura
	   from rectrmae
	  where no_reclamo   = _no_reclamo
	    and actualizado  = 1
		and cod_tipotran = _cod_tipotran

		if _fecha_factura is null then
			let _fecha_factura = _fecha_gasto;
		end if

		--if a_ano <> "*" then
			if _fecha_factura <= a_fecha_desde or _fecha_factura >= a_fecha_hasta then  
	 		   continue foreach;
				--     if year(_fecha_factura) <> a_ano then
			  	--        continue foreach;
			end if
		--end if		   	 

		if _cod_cpt is null then
			let _cod_cpt = "";
		end if

{
		select nombre
		  into _nombre_cpt
		  from reccpt
		 where cod_cpt = _cod_cpt;
}

		select nombre
		  into _nombre_prov
		  from cliclien
		 where cod_cliente = _cod_proveedor;

		foreach
		 select	facturado,
		        elegible,
				a_deducible,
				co_pago,
				coaseguro,
				monto,
				monto_no_cubierto
		   into	_gasto_fact,
		        _gasto_eleg,
				_a_deducible,
				_co_pago,
				_coaseguro,
				_pago_prov,
				_gastos_no_cub
		   from rectrcob
		  where no_tranrec = _no_tranrec

			return _numrecla,		   -- 1
			       _fecha_factura,     -- 2
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
				 --  _filtro_ano,		   -- 22
				   _filtro_aseg,	   -- 23
				   _filtro_recla,	   -- 24
				   _periodo,		   -- 25
				   _dependencia,	   -- 26
				   _nombre_icd,		   -- 27
				   _no_unidad,		   -- 28 N£mero de Unidad
				   v_producto,   	   -- 29 Nombre del Producto
				   _cod_proveedor      -- 30 C¢digo de Proveedor   
				   with resume;

		end foreach

	end foreach

end foreach

end procedure;
