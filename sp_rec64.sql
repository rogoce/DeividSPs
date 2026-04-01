-- Bordero de Reclamos Para el Reasegurador

-- Creado    : 22/02/2002 - Autor: Amado Perez	 
-- Modificado: 22/02/2002 - Autor: Amado Perez
--
-- SIS v.2.0 - d_recl_sp_rec55_dw1 - DEIVID, S.A.

drop procedure sp_rec64;

create procedure sp_rec64(a_compania char(3),a_ano char(7), a_ano2 char(7), a_cod_asegurado char(10) default "*", a_cod_reclamante char(10) default "*")
returning char(20),	
          char(20),			 
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
		  char(50),				
		  char(100),			
		  char(100),			
		  char(7),				
		  char(50),
		  char(100),
		  int,
		  date,
		  dec(16,2);	

define _numrecla		char(20);
define _no_documento    char(20);
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
define _dependencia,_desc_transaccion		char(100);
define _cod_parentesco  char(3);
define _no_tranrec		char(10);
define _cod_ramo        char(3);
define _no_requis       char(10);
define _no_cheque       int;
define _fecha_impresion date;
define _ahorro          dec(16,2);
define _mes             char(2);
define _ano             char(4);
define _ramo_sis		smallint;

define _nombre_icd		char(100);

--define _nombre_cpt		char(100);

set isolation to dirty read;

select cod_tipotran
  into _cod_tipotran
  from rectitra
 where tipo_transaccion = 4;

let _nombre_cia = sp_sis01(a_compania); 
	
-- Descripcion de Filtros

if a_ano = "*" then
	let _filtro_ano = "Todos los Años";
else
	let _filtro_ano = a_ano;
end if

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

	-- Transacciones de Reclamos

FOREACH
	 select cod_cliente,
			fecha,
			no_tranrec,
			no_requis,
			ahorro,
			no_reclamo
	   into	_cod_proveedor,
			_fecha_gasto,
			_no_tranrec,
			_no_requis,
			_ahorro,
			_no_reclamo
	   from rectrmae
	  where periodo     >= a_ano
	    and periodo     <= a_ano2
	    and actualizado  = 1
		and cod_tipotran = _cod_tipotran

	 select	a.numrecla,
	        a.no_documento,
			a.cod_icd,
			a.cod_cpt,
	        a.fecha_siniestro,
			a.cod_reclamante,
			a.cod_asegurado,
			a.no_reclamo,
			a.no_unidad,
			a.no_poliza,
			a.periodo
	   into	_numrecla,
	        _no_documento,
			_cod_icd,
			_cod_cpt,
	        _fecha_siniestro,
			_cod_reclamante,
			_cod_contratante,
			_no_reclamo,
			_no_unidad,
			_no_poliza,
			_periodo
	   from recrcmae a
	  where	a.actualizado    = 1
		and a.cod_reclamante matches a_cod_reclamante
		and a.no_reclamo = _no_reclamo;

		select cod_ramo
		  into _cod_ramo
		  from emipomae
		 where no_poliza = _no_poliza;

		select ramo_sis
		  into _ramo_sis
		  from prdramo
		 where cod_ramo = _cod_ramo;

		if _ramo_sis <> 5 then
		   continue foreach;
		end if

		select vigencia_inic,
		       vigencia_final
		  into _vigencia_inic,
		       _vigencia_final
		  from emipomae
		 where no_poliza = _no_poliza;

		IF _cod_icd is null OR _cod_icd = "" then

		   LET _nombre_icd = "";

		   FOREACH
			select desc_transaccion
			  into _desc_transaccion
			  from rectrde2
	 		 where no_tranrec = _no_tranrec

			IF _desc_transaccion is null then
				let _desc_transaccion = "";
			END IF

			LET _nombre_icd = TRIM(_nombre_icd) || TRIM(_desc_transaccion);
		   END FOREACH
			LET _cod_icd    = "";
		ELSE
			select nombre
			  into _nombre_icd
			  from recicd
			 where cod_icd = _cod_icd;
		END IF

		IF _cod_cpt is null then
			let _cod_cpt = "";
		END IF

	{
		select nombre
		  into _nombre_cpt
		  from reccpt
		 where cod_cpt = _cod_cpt;
	}

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

		if a_cod_asegurado <> "*" then 
			if a_cod_asegurado <> _cod_asegurado then
				continue foreach;
			end if
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

		select nombre
		  into _nombre_prov
		  from cliclien
		 where cod_cliente = _cod_proveedor;

		select no_cheque,
		       fecha_impresion
		  into _no_cheque,
		       _fecha_impresion
		  from chqchmae
		 where no_requis = _no_requis;  

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

			return _numrecla,		    -- 1
			       _no_documento,       -- 2
			       _fecha_siniestro,    -- 3
				   _cod_icd,		    -- 4
				   _cod_cpt,		    -- 5
				   _gasto_fact,		    -- 5	
				   _gasto_eleg,		    -- 6	
				   _a_deducible,	    -- 7
				   _co_pago,		    -- 8	
				   _coaseguro,		    -- 9
				   _pago_prov,		    -- 10
				   _nombre_prov,	    -- 11	
				   _gastos_no_cub,	    -- 12
				   _nombre_cont,	    -- 13
				   _nombre_recla,	    -- 14
				   _cod_contratante,    -- 15
				   _cod_reclamante,	    -- 16
				   _nombre_cia,		    -- 17
				   _cod_asegurado,	    -- 18
				   _nombre_aseg,	    -- 19
				   _vigencia_inic,	    -- 20
				   _vigencia_final,	    -- 21
				   _filtro_ano,		    -- 22
				   _filtro_aseg,	    -- 23
				   _filtro_recla,	    -- 24
				   _periodo,		    -- 25
				   _dependencia,	    -- 26
				   _nombre_icd,		    -- 27	
				   _no_cheque,          -- 28
				   _fecha_impresion,    -- 29
				   _ahorro				-- 30
				   with resume;		    
									  
		end foreach					  
									  
	end foreach						  
									  
									  
end procedure;						  
									  
									  
									  
									  
									  
									  
									  
									  
									  
									  
									  
									  
									  
									  
									  
									  
									  
									  