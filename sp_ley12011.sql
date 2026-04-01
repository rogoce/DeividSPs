-- Informacion requerida por Leyri sobre orden de compra y reparacion ener a dic 2010

-- Modificado: 07/02/2011 - Autor: Armando Moreno Montenegro

--drop procedure sp_ley12011;

create procedure "informix".sp_ley12011()
returning  char(19),varchar(100),date,dec(16,2),varchar(50),char(8),date,char(10);


define _no_reclamo	   char(10);
define _numrecla	   char(19);
define _n_proveedor    varchar(100);
define _n_ajustador    varchar(50);
define _no_orden	   char(5);
define _cod_proveedor  char(10);
define _fecha_orden	   date;
define _monto		   dec(16,2);
define _cod_ajustador  char(3);
define _entregar_a	   varchar(50);
define v_fech_cot      date;
define _wf_apr_j       char(8);
define _wf_apr_jt	   char(8);
define _no_tranrec	   char(10);

--SET DEBUG FILE TO "sp_sis145.trc";
--TRACE ON;

SET ISOLATION TO DIRTY READ;

let _monto = 0;

foreach

	select no_orden,
	       no_reclamo,
		   cod_proveedor,
		   fecha_orden,
		   monto,
		   cod_ajustador,
		   entregar_a,
		   no_tranrec
	  into _no_orden,
	       _no_reclamo,
		   _cod_proveedor,
		   _fecha_orden,
		   _monto,
		   _cod_ajustador,
		   _entregar_a,
		   _no_tranrec
	  from recordma
	 where actualizado = 1
	   and tipo_ord_comp = "R"
	   and year(fecha_orden) = 2010

    SELECT fecha,
		   wf_apr_j,
		   wf_apr_jt
	  INTO v_fech_cot,
		   _wf_apr_j,
		   _wf_apr_jt
	  FROM rectrmae
	 WHERE no_tranrec = _no_tranrec;

	if _wf_apr_j is null or _wf_apr_j = "" then
		let _wf_apr_j = _wf_apr_jt;
	end if

	 select numrecla
	   into _numrecla
	   from recrcmae
	  where no_reclamo = _no_reclamo;

	 select nombre
	   into _n_proveedor
	   from cliclien
	  where cod_cliente = _cod_proveedor;

	 select nombre
	   into _n_ajustador
	   from recajust
	  where cod_ajustador = _cod_ajustador;

	 return _numrecla,_n_proveedor,v_fech_cot,_monto,_n_ajustador,_wf_apr_j,_fecha_orden,_no_orden with resume;

end foreach

end procedure
