-- Procedimiento que Realiza la Facturacion de Salud

-- Creado    : 16/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 19/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_prod_sp_pro30a_dw1 - DEIVID, S.A.
					   
DROP PROCEDURE sp_pro30z;
CREATE PROCEDURE sp_pro30z(a_compania CHAR(3), a_sucursal CHAR(3), a_periodo CHAR(7), a_documento CHAR(20) DEFAULT '*') 
RETURNING CHAR(10),
		  CHAR(5),
		  CHAR(100),
		  CHAR(1),
		  CHAR(30),
		  DATE,
		  DATE,
		  DATE,
		  DEC(16,2),
		  DEC(16,2),
		  DEC(16,2),
		  CHAR(100),
		  CHAR(20),
		  DATE,
		  CHAR(50),
		  CHAR(50),
		  DATE,
		  DATE,
		  CHAR(10);

DEFINE 	_no_poliza, _no_factura	 CHAR(10);
DEFINE 	_no_unidad   CHAR(5);
DEFINE 	_nombre		 CHAR(100);
DEFINE 	_plan		 CHAR(1);
DEFINE 	_cedula		 CHAR(30);
DEFINE 	_fecha_nac	 DATE;
DEFINE 	_fecha_emis	 DATE;
DEFINE 	_fecha_efec	 DATE;
DEFINE 	_prima_net   DEC(16,2);
DEFINE 	_impuesto	 DEC(16,2);
DEFINE 	_prima_bru	 DEC(16,2);
DEFINE 	_contratante CHAR(100);
DEFINE  _doc_poliza  CHAR(20);
DEFINE 	_vigen_inic	 DATE;
DEFINE 	_subramo	 CHAR(50);
DEFINE 	_compania    VARCHAR(50);
DEFINE 	_vigencia_i  DATE;
DEFINE 	_vigencia_f  DATE;

SET ISOLATION TO DIRTY READ;

-- Nombre de la Compania

--LET _nombre_compania = sp_sis01(a_compania); 

CALL sp_pro301(a_compania,a_sucursal,a_periodo);

if a_documento <> '*' then
	DELETE FROM tmp_certif
	 WHERE doc_poliza <> a_documento;
end if

FOREACH
 SELECT	no_poliza,	
	    no_unidad,   
	    nombre,
	    plan,		
	    cedula,		
	    fecha_nac,	
	    fecha_emis,	
	    fecha_efec,	
	    prima_net,
	    impuesto,
	    prima_bru,
	    contratante,
        doc_poliza,  
	    vigen_inic,	
	    subramo,		
	    compania,
	    vigencia_i,
	    vigencia_f,
	    no_factura    
   INTO	_no_poliza,	
	    _no_unidad,   
	    _nombre,
	    _plan,		
	    _cedula,		
	    _fecha_nac,	
	    _fecha_emis,	
	    _fecha_efec,	
	    _prima_net,
	    _impuesto,
	    _prima_bru,
	    _contratante,
        _doc_poliza,  
	    _vigen_inic,	
	    _subramo,		
	    _compania,
	    _vigencia_i,
	    _vigencia_f,
	    _no_factura    
   FROM tmp_certif
  WHERE doc_poliza matches a_documento
  ORDER BY doc_poliza, no_factura, nombre

   RETURN _no_poliza,	
	      _no_unidad,   
	      _nombre,
	      _plan,		
	      _cedula,		
	      _fecha_nac,	
	      _fecha_emis,	
	      _fecha_efec,	
	      _prima_net,
	      _impuesto,
	      _prima_bru,
	      _contratante,
          _doc_poliza,  
	      _vigen_inic,	
	      _subramo,		
	      trim(_compania),
	      _vigencia_i,
	      _vigencia_f,
	      _no_factura
		  WITH RESUME;

END FOREACH

commit work;

END PROCEDURE;
