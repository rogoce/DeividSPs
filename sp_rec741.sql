-- Procedimiento que busca si se imprime el finiquito

-- Creado    : 29/03/2011 - Autor: Amado Perez
-- Copia del sp_che67

 drop procedure sp_rec741;

 create procedure sp_rec741(a_mail_secuencia integer)
 returning varchar(100);

define _a_nombre_de		varchar(100);
define _no_tranrec		char(10);
define _monto_tot		dec(16,2);
define _monto_rec       dec(16,2);
define _ano_cal         integer;
define _no_reclamo      char(10);
define _no_poliza       char(10);
define _no_unidad       char(5);
define _fecha_factura   date;
define _cod_reclamante  char(10);
define _vigencia_inic   date;
define _reemplaza_poliza char(20);
define _no_endoso       char(5);
define _no_endoso_r     char(5);
define _no_poliza_r     char(10);
define _cod_producto    char(5);
define _tipo_acum_deduc smallint;
define _ano_cal_int     integer;
define _descripcion     char(255);
define _numrecla        char(20);
define _transaccion     char(10);
define _error           integer;

set isolation to dirty read;

let _monto_tot = 0;
let _monto_rec = 0;
let _ano_cal = null;

foreach
	select no_remesa
	  into _no_tranrec
	  from parmailcomp
	 where mail_secuencia = a_mail_secuencia
	group by no_remesa

	select no_reclamo,
	       fecha_factura,
		   transaccion
   	  into _no_reclamo,
	       _fecha_factura,
		   _transaccion
	  from rectrmae
	 where no_tranrec = _no_tranrec;
	 
	select cod_reclamante,
	       no_poliza,
		   no_unidad,
		   numrecla
	  into _cod_reclamante,
	       _no_poliza,
		   _no_unidad,
		   _numrecla
	  from recrcmae
	 where no_reclamo = _no_reclamo;
	 
	select nombre
	  into _a_nombre_de
	  from cliclien
	 where cod_cliente = _cod_reclamante;
	 	 
	exit foreach;
 end foreach

 return _a_nombre_de;
 
drop table tmp_ded_agno;
end procedure
