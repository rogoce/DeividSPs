-- Procedimiento que retorna las transacciones autorizadas pendientes de Imprimir
-- 
-- Creado     : 20/12/2004 - Autor: Demetrio Hurtado Almanza
--
-- SIS v.2.0 - d_recl_transacciones_por_imprimir - DEIVID, S.A.

DROP PROCEDURE sp_rwf38;		

CREATE PROCEDURE "informix".sp_rwf38(a_user_added char(8))
returning char(20),
	      char(10),
	      char(50),
		  dec(16,2),
		  dec(16,2),
		  char(50),
		  char(50),
		  char(8),    
		  datetime year to fraction(5), 
		  char(8),   
		  datetime year to fraction(5),
		  char(8),    
		  datetime year to fraction(5),
		  smallint,
		  char(10),
		  char(8),
		  char(10),
		  char(3),
		  char(3);

define _numrecla		char(20);
define _transaccion		char(10);
define _cod_cliente		char(10);
define _monto			dec(16,2);
define _variacion		dec(16,2);
define _cod_tipotran	char(3);
define _cod_tipopago	char(3);

define _nombre_cliente	char(50);
define _nombre_tipotran	char(50);
define _nombre_tipopago	char(50);

define _wf_apr_j        char(8);
define _wf_apr_j_fh     datetime year to fraction(5);
define _wf_apr_jt       char(8);
define _wf_apr_jt_fh    datetime year to fraction(5);
define _wf_apr_g        char(8);
define _wf_apr_g_fh     datetime year to fraction(5);

define _impreso	    smallint;
define _no_tranrec	char(10);
define _user_added	char(8);
define _no_reclamo	char(10);

set isolation to dirty read;

foreach
 select numrecla,
        transaccion,
        cod_cliente,
		monto,
		variacion,
		cod_tipotran,
		cod_tipopago,
		wf_apr_j,    
		wf_apr_j_fh, 
		wf_apr_jt,   
		wf_apr_jt_fh,
		wf_apr_g,    
		wf_apr_g_fh,
		impreso,
		no_tranrec,
		user_added,
		no_reclamo 
   into _numrecla,
        _transaccion,
        _cod_cliente,
		_monto,
		_variacion,
		_cod_tipotran,
		_cod_tipopago,
		_wf_apr_j,    
		_wf_apr_j_fh, 
		_wf_apr_jt,   
		_wf_apr_jt_fh,
		_wf_apr_g,    
		_wf_apr_g_fh,
		_impreso,
		_no_tranrec,
		_user_added,
		_no_reclamo 
   from rectrmae
  where actualizado = 1
    and wf_aprobado = 1
	and impreso     = 0
	and user_added  like a_user_added

	select nombre
	  into _nombre_cliente
	  from cliclien
	 where cod_cliente = _cod_cliente;

	select nombre
	  into _nombre_tipotran
	  from rectitra
	 where cod_tipotran = _cod_tipotran;

	select nombre
	  into _nombre_tipopago
	  from rectipag
	 where cod_tipopago = _cod_tipopago;

	If trim(a_user_added) = '%' then
		let _impreso = 0;
	Else
		let _impreso = 1;
	end if
	return _numrecla,
	       _transaccion,
	       _nombre_cliente,
		   _monto,
		   _variacion,
		   _nombre_tipotran,
		   _nombre_tipopago,
		   _wf_apr_j,    
		   _wf_apr_j_fh, 
		   _wf_apr_jt,   
		   _wf_apr_jt_fh,
		   _wf_apr_g,    
		   _wf_apr_g_fh,
		   _impreso,
		   _no_tranrec,
		   _user_added,
		   _no_reclamo,
		   _cod_tipotran,
		   _cod_tipopago 
		   with resume;
	       
end foreach

end procedure