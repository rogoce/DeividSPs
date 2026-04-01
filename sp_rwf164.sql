-- Procedimiento busca quien aprueba las transacciones

-- Creado    : 07/12/2018 - Autor: Amado Perez  

drop procedure sp_rwf164;

create procedure sp_rwf164(a_no_requis CHAR(10)) 
returning char(10),
          char(3),
		  dec(16,2),
		  char(20),
		  char(10);

define _transaccion       char(10);
define _monto             dec(16,2);
define _numrecla          char(20);
define _no_tranrec        char(10);
define _cod_tipotran      char(3); 
define _no_reclamo        char(10);

--SET DEBUG FILE TO "sp_rec161.trc"; 
--trace on;

set isolation to dirty read;

FOREACH
  SELECT transaccion,
         monto,
         numrecla		 
    INTO _transaccion,
         _monto,
         _numrecla		 
    FROM chqchrec  
   WHERE no_requis = a_no_requis
  EXIT FOREACH;
END FOREACH	 
  
SELECT no_tranrec,
       cod_tipotran,
	   no_reclamo
  INTO _no_tranrec,
       _cod_tipotran,
	   _no_reclamo
  FROM rectrmae
 WHERE transaccion = _transaccion
   AND numrecla = _numrecla;

 RETURN _no_tranrec,
        _cod_tipotran,
		_monto,
		_numrecla,
		_no_reclamo;
   
end procedure