-- Reclamos pagados de automovil (incluye todos los ramos)
-- Creado     : 25/09/2017 - Autor: Henry Giron. CASO: 26275
drop procedure sp_rec275;
create procedure sp_rec275(a_compania char(3), a_periodo1 char(7), a_periodo2 char(7), a_ramo char(255) default '*')
RETURNING CHAR(18) as numrecla,
		CHAR(20) as no_poliza,
		CHAR(100) as asegurado,  
		CHAR(100) as proveedor,
		DEC(16,2) as monto,
		VARCHAR(50) as ramo_nombre,
		VARCHAR(50) as n_cod_concepto,
		VARCHAR(50) as compania_nombre,
		VARCHAR(255) as filtros,
		VARCHAR(50) as cod_cobertura,
		DEC(16,2) as monto2,
		CHAR(10) as no_tramite,
		CHAR(10) as no_transaccion,
		CHAR(500) as tipo_transaccion, 
		CHAR(50) as tipo_pago,
		DATE as fecha_pagado,  		
		CHAR(2) as perdida_total,
		CHAR(20) as estado_audiencia,
		CHAR(50) as n_cobertura,
		CHAR(50) as n_concepto,
		CHAR(50) as ajustador; 		

define _cod_cliente_rec		char(10);
define _monto			dec(16,2);
define _nom_aseg		char(100);
define _cod_asegurado	char(10);
define _no_reclamo		char(10);
define _fecha_pagado		date;
define _transaccion		char(10);
define _reclamo			char(18);
define _cod_proveedor   char(10);
define _n_proveedor		char(100);
DEFINE _no_poliza       CHAR(10);
define _periodo 		char(7);
DEFINE _cod_ramo        CHAR(3);
DEFINE _doc_poliza      CHAR(20);
DEFINE v_filtros        CHAR(255);
DEFINE _tipo            CHAR(01);
DEFINE _cantidad        smallint;
DEFINE _estatus_audiencia smallint;
DEFINE _perd_total        smallint;
DEFINE _no_tramite      char(10);
DEFINE _nom_rectitra    char(50);
DEFINE _n_estatus_audiencia      char(20);
DEFINE _n_perd_total    char(2);
define _cod_concepto    char(3);
define _n_cod_concepto  char(50);
define _cod_tipotran    char(3);
define _no_tranrec      char(10);
define _cod_cobertura   char(5);

DEFINE v_numrecla        		CHAR(18);
DEFINE v_no_poliza       		CHAR(20);
DEFINE v_asegurado       		CHAR(100);
DEFINE v_proveedor              CHAR(100);
DEFINE v_ramo_nombre     		VARCHAR(50);
DEFINE v_concepto_nombre        VARCHAR(50);
DEFINE v_cobertura_nombre       VARCHAR(50);
DEFINE v_compania_nombre 		VARCHAR(50);
DEFINE v_monto                  dec(16,2);
DEFINE _pago_asegurado          DEC(16,2);
DEFINE v_pago_asegurado_tot     DEC(16,2);
DEFINE _cod_concepto_tr         CHAR(3);
define _tipo_pago               char(50);
DEFINE _cod_ajustador           CHAR(3);
define _nom_recajust            char(50);
define _n_cod_ramo              char(50);
define _n_cod_cobertura         char(50);

  drop table if exists tmp_auto0;
CREATE TEMP TABLE tmp_auto0(        
		no_tramite           CHAR(10) NOT NULL,
		no_transaccion       CHAR(10) NOT NULL,
		tipo_transaccion     CHAR(50)  NOT NULL, 
		tipo_pago            CHAR(50)  NOT NULL,
		fecha_pagado         DATE,  		
		perdida_total        CHAR(2)  NOT NULL,
		estado_audiencia     CHAR(20)  NOT NULL,
		n_cobertura          CHAR(50)  NOT NULL,
		n_concepto           CHAR(50)  NOT NULL,
		ajustador		     CHAR(50)  NOT NULL, 
		no_reclamo           CHAR(10)  NOT NULL,
		cod_concepto         CHAR(3)   NOT NULL,
		cod_cobertura        CHAR(5)   NOT NULL,
		cod_cliente          CHAR(10)  NOT NULL,
		numrecla             CHAR(18)  NOT NULL,
		no_poliza            CHAR(20)  NOT NULL,
		asegurado            CHAR(100) NOT NULL,
		a_nombre_de          CHAR(100) NOT NULL,
		monto                DEC(16,2) DEFAULT 0.00,
		cod_ramo             CHAR(3)   NOT NULL,
		periodo              CHAR(7)   NOT NULL,		
		seleccionado         SMALLINT  DEFAULT 1 NOT NULL,
		PRIMARY KEY (no_reclamo, cod_concepto, cod_cobertura, cod_cliente)
		) WITH NO LOG;

SET ISOLATION TO DIRTY READ;
LET v_compania_nombre = sp_sis01(a_compania);
LET v_filtros ="";

foreach
	select t.no_tranrec,
		   t.no_reclamo,
		   t.cod_cliente,
		   t.periodo,
		   a.nombre,
		   t.cod_tipotran,
		   t.transaccion,
		   t.fecha_pagado
	  into _no_tranrec,
		   _no_reclamo,
		   _cod_cliente_rec,
		   _periodo,
           _tipo_pago,
		   _cod_tipotran,
		   _transaccion,
		   _fecha_pagado
      from rectrmae t, rectipag a 
where  t.cod_tipopago = a.cod_tipopago
   and a.cod_tipopago in ('003','017')  -- CHAPISTERIA, PIEZAS
   and t.cod_tipotran = '004'           -- Pago del Reclamo
   and t.periodo between a_periodo1 and a_periodo2
   and t.actualizado = 1
   --and t.pagado      = 1   
   and t.monto <> 0
   and t.anular_nt is null
   and t.no_requis is not null   
   and t.cod_compania = a_compania	   
   and t.numrecla = '23-0816-00041-03'
	
	select nombre
	  into _n_proveedor
	  from cliclien
	 where cod_cliente = _cod_cliente_rec; 
	 
	select cod_asegurado,
		   numrecla,
		   no_poliza,
		   no_documento,
		   no_tramite,
		   estatus_audiencia,
		   perd_total,
		   ajust_interno
	  into _cod_asegurado,
		   _reclamo,
		   _no_poliza,
		   _doc_poliza,
		   _no_tramite,
		   _estatus_audiencia,
		   _perd_total,
		   _cod_ajustador
	  from recrcmae
	 where no_reclamo = _no_reclamo; 
	 
       if  _estatus_audiencia = 0 then 
	       LET _n_estatus_audiencia = 'Perdido';
	   ELIF _estatus_audiencia = 1 then 
	       LET _n_estatus_audiencia = 'Ganado' ;
	   ELIF _estatus_audiencia = 2 then 
	       LET _n_estatus_audiencia = 'Por Definir'; 
	   ELIF _estatus_audiencia = 3 then 
	       LET _n_estatus_audiencia = 'Proceso Penal'; 
	   ELIF  _estatus_audiencia = 4 then 
	       LET _n_estatus_audiencia = 'Proceso Civil'; 
	   ELIF _estatus_audiencia = 5 then 
	       LET _n_estatus_audiencia = 'Apelacion' ;
	   ELIF _estatus_audiencia = 6 then 
	       LET _n_estatus_audiencia = 'Resuelto'; 
	   ELIF _estatus_audiencia = 7 then 
	       LET _n_estatus_audiencia = 'FUT - Ganado';
	   ELse  
	       LET _n_estatus_audiencia = 'FUT - Responsable';
	   end if
	   
		IF _perd_total = 1 THEN
			LET  _n_perd_total = 'SI';
		ELSE
			LET  _n_perd_total = 'NO';
		END IF	   	 	 
	 
	select nombre
	  into _nom_aseg
	  from cliclien
	 where cod_cliente = _cod_asegurado;	 
	 
	select cod_ramo
      into _cod_ramo
      from emipomae
     where no_poliza = _no_poliza;	  
	 
	select nombre
	  into _nom_rectitra
	  from rectitra
	 where cod_tipotran =  _cod_tipotran;
	 
	select nombre
	  into _nom_recajust
      from recajust
     where cod_ajustador = _cod_ajustador;		 	 
	 
	select nombre
	  into _n_cod_ramo
	  from prdramo 
	 where cod_ramo = _cod_ramo;	 
  
	foreach
		select cod_concepto,
		       monto
		  into _cod_concepto,
		       _monto
		  from rectrcon
		 where no_tranrec = _no_tranrec
		   and monto <> 0
		   
		select nombre 
		  into _n_cod_concepto
		  from recconce
		 where cod_concepto = _cod_concepto	; 		   
		 
		foreach
			select cod_cobertura,
			       monto
			  into _cod_cobertura,
			       _monto
			  from rectrcob 
		     where no_tranrec = _no_tranrec
			 
			select nombre
			  into _n_cod_cobertura
			  from prdcober 
			 where cod_cobertura = _cod_cobertura;				 			 			 
		 
			begin
				on exception in(-239)
					update tmp_auto0
					   set monto = monto + _monto
					 where no_reclamo = _no_reclamo
					   and cod_concepto = _cod_concepto
					   and cod_cobertura = _cod_cobertura
					   and cod_cliente = _cod_cliente_rec;
				
				end exception
				insert into tmp_auto0 			
				values (_no_tramite,
					_transaccion,
					_nom_rectitra, 
					_tipo_pago,
					_fecha_pagado,  		
					_n_perd_total,
					_n_estatus_audiencia,
					_n_cod_cobertura,
					_n_cod_concepto,
					_nom_recajust, 
					_no_reclamo,
					_cod_concepto,
					_cod_cobertura,
					_cod_cliente_rec,
					_reclamo,
					_doc_poliza,
					_nom_aseg,
					_n_proveedor,
					_monto,
					_cod_ramo,
					_periodo,
					1
					);
			end
		end foreach
	end foreach

end foreach
   
IF a_ramo <> "*" THEN

	LET v_filtros = TRIM(v_filtros) || " Ramo: " ||  TRIM(a_ramo);

	LET _tipo = sp_sis04(a_ramo);  -- Separa los Valores del String en una tabla de codigos

	IF _tipo <> "E" THEN -- (I) Incluir los Registros

		UPDATE tmp_auto0
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo NOT IN (SELECT codigo FROM tmp_codigos);

	ELSE		        -- (E) Excluir estos Registros

		UPDATE tmp_auto0
		   SET seleccionado = 0
		 WHERE seleccionado = 1
		   AND cod_ramo IN (SELECT codigo FROM tmp_codigos);

	END IF

	DROP TABLE tmp_codigos;

END IF

FOREACH 
 SELECT no_reclamo,
        cod_concepto,
		cod_cobertura,
		numrecla,
		no_poliza,
		asegurado,
		a_nombre_de,
		monto,
		cod_ramo,
		no_tramite,
		no_transaccion,
		tipo_transaccion,
		tipo_pago,
		fecha_pagado,
		perdida_total,
		estado_audiencia,
		n_cobertura,
		n_concepto,
		ajustador
   INTO _no_reclamo,
        _cod_concepto,
        _cod_cobertura,
		v_numrecla,
		v_no_poliza,
		v_asegurado,
		v_proveedor,
		v_monto,
		_cod_ramo,
		_no_tramite,
		_transaccion,
		_nom_rectitra, 
		_tipo_pago,
		_fecha_pagado,  		
		_n_perd_total,
		_n_estatus_audiencia,
		_n_cod_cobertura,
		_n_cod_concepto,
		_nom_recajust
   FROM tmp_auto0
  WHERE seleccionado = 1
  ORDER BY cod_ramo, cod_concepto, cod_cobertura, numrecla
    
	SELECT nombre
	  INTO v_ramo_nombre
	  FROM prdramo 
	 WHERE cod_ramo = _cod_ramo;	 	 	
	 
	RETURN v_numrecla,        
			v_no_poliza,       
			v_asegurado,  
			v_proveedor,
			v_monto,		   
			v_ramo_nombre,
			_n_cod_concepto,
			v_compania_nombre,
			v_filtros,
			_n_cod_cobertura,
			v_monto,
			_no_tramite,
			_transaccion,
			_nom_rectitra, 
			_tipo_pago,
			_fecha_pagado,  		
			_n_perd_total,
			_n_estatus_audiencia,
			_n_cod_cobertura,
			_n_cod_concepto,
			_nom_recajust
		   WITH RESUME;

END FOREACH

end procedure  	