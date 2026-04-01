-- Procedimiento para generacion de cheques
-- 
-- creado: 20/12/2004 - Autor: Amado Perez.

--DROP PROCEDURE sp_rwf40;
CREATE PROCEDURE "informix".sp_rwf40(a_no_tranrec CHAR(10)) 
			RETURNING CHAR(10), VARCHAR(100), DEC(16,2);  

DEFINE _no_requis			CHAR(10);
DEFINE _monto				DEC(16,2);
DEFINE _nombre			    VARCHAR(100);  

SET ISOLATION TO DIRTY READ;

 SELECT no_requis,
		monto
   INTO _no_requis,
		_monto
   FROM rectrmae
  WHERE no_tranrec = a_no_tranrec;

 SELECT a_nombre_de
   INTO _nombre
   FROM chqchmae
  WHERE no_requis = _no_requis;


 RETURN _no_requis, _nombre, _monto;
END PROCEDURE