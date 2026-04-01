-- Procedimiento para la consulta de cheques en la consulta de Recibos
-- 
-- Creado    : 04/02/2010 - Autor: Armando Moreno
-- Modificado: 04/02/2010 - Autor: Armando Moreno
--
-- SIS v.2.0 - DEIVID, S.A.

DROP PROCEDURE sp_cob236;

CREATE PROCEDURE "informix".sp_cob236(a_cheque integer)
RETURNING DATE,
		  CHAR(100),
		  CHAR(10),
		  SMALLINT,
		  CHAR(10),
		  CHAR(30),
		  smallint,
		  smallint,
		  CHAR(3),
		  CHAR(50),
		  CHAR(100),
		  dec(16,2),
		  smallint;

DEFINE _fecha             DATE;
DEFINE _no_remesa         CHAR(10);
DEFINE _renglon           SMALLINT;					
DEFINE _no_recibo         CHAR(10);					
DEFINE _doc_remesa        CHAR(30);					
DEFINE _n_banco     	  CHAR(50);					
DEFINE _tipo_pago		  smallint;
DEFINE _tipo_tarjeta	  smallint;
DEFINE _cod_banco 		  char(3);
DEFINE _girado_por		  char(100);
DEFINE _importe			  DEC(16,2);
DEFINE _rgl				  smallint;
DEFINE _a_favor_de		  char(100);

												
SET ISOLATION TO DIRTY READ;						
													

foreach

  SELECT c.no_remesa,   
         c.renglon,   
         c.tipo_pago,   
         c.tipo_tarjeta,   
         c.cod_banco,   
         c.fecha,   
         c.girado_por,   
         c.a_favor_de,   
         c.importe,
         d.doc_remesa,
		 d.renglon,
		 d.no_recibo
	INTO _no_remesa,
	     _renglon,
		 _tipo_pago,
		 _tipo_tarjeta,
		 _cod_banco,   
		 _fecha,   
		 _girado_por,  
		 _a_favor_de,
		 _importe,
		 _doc_remesa,
		 _rgl,
		 _no_recibo
    FROM cobrepag c, cobredet d
   WHERE c.no_remesa = d.no_remesa
	 AND c.no_cheque = a_cheque
   ORDER BY c.fecha

   select nombre
     into _n_banco
	 from chqbanco
	where cod_banco = _cod_banco;

		RETURN _fecha,
			   _a_favor_de,
			   _no_remesa,
			   _renglon,
			   _no_recibo,
			   _doc_remesa, 
			   _tipo_pago,
			   _tipo_tarjeta, 
			   _cod_banco, 
			   _n_banco,
			   _girado_por,
			   _importe,
			   _rgl
			   WITH RESUME;

end foreach

END PROCEDURE;
