-- Actualizacion del codigo de un contrato inactivo por otro codigo de contrato de reaseguro

-- SIS v.2.0 - DEIVID, S.A.
-- Creado    : 28/09/2012 - Autor: Armando Moreno

DROP procedure sp_sim007;

CREATE procedure "informix".sp_sim007(a_cod_cont_nvo CHAR(05),a_cod_cont_ant CHAR(05),a_user char(8))
RETURNING    integer,char(100);


define _no_poliza char(10);
define _no_endoso char(5);
define _no_remesa char(10);
define _renglon   integer;

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

define _no_unidad	       char(5);
define _cod_cober_reas	   char(3);
define _orden			   smallint;
define _cod_contrato	   char(5);
define _porc_partic_prima  decimal(9,6);
define _prima			   decimal(16,2);
define _no_tranrec         char(10);


set isolation to dirty read;

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

let _error  = 0;
let _error_desc = "Proceso Inactivo...";	
return _error, _error_desc;

update emifafac
   set cod_contrato = a_cod_cont_nvo
 where cod_contrato = a_cod_cont_ant;

foreach

	select no_poliza,
		   no_endoso,
		   no_unidad,
		   cod_cober_reas,
		   orden,
		   cod_contrato,
		   porc_partic_prima,
		   prima
	  into _no_poliza,
		   _no_endoso,
		   _no_unidad,
		   _cod_cober_reas,
		   _orden,
		   _cod_contrato,
		   _porc_partic_prima,
		   _prima
	  from semifacon
	 order by 1,2,3,4

	update emifacon
	   set cod_contrato      = _cod_contrato,
	       porc_partic_prima = _porc_partic_prima,
		   prima			 = _prima
	 where no_poliza	     = _no_poliza
	   and no_endoso	     = _no_endoso
	   and no_unidad	     = _no_unidad
	   and cod_cober_reas    = _cod_cober_reas
	   and orden		     = _orden;

	update emireaco
	   set cod_contrato      = _cod_contrato,
	       porc_partic_prima = _porc_partic_prima
 	 where no_poliza	     = _no_poliza
	   and no_unidad	     = _no_unidad
	   and cod_cober_reas    = _cod_cober_reas
	   and orden		     = _orden;

	update emigloco
	   set cod_contrato      = _cod_contrato,
	       porc_partic_prima = _porc_partic_prima
 	 where no_poliza	     = _no_poliza
	   and no_endoso	     = _no_endoso
	   and orden		     = _orden;


end foreach

foreach

	select no_remesa,
		   renglon,
		   orden,
		   cod_contrato,
		   porc_partic_prima
	  into _no_remesa,
		   _renglon,
		   _orden,
		   _cod_contrato,
		   _porc_partic_prima
	  from scobreaco
	 order by 1,2,3,4

    update cobreaco
	   set cod_contrato      = _cod_contrato,
	       porc_partic_prima = _porc_partic_prima
	 where no_remesa         = _no_remesa
	   and renglon           = _renglon
	   and orden             = _orden;

end foreach

update cobreafa
   set cod_contrato = a_cod_cont_nvo
 where cod_contrato = a_cod_cont_ant;

foreach

	select no_tranrec,
		   orden,
		   cod_contrato,
		   porc_partic_prima
	  into _no_tranrec,
		   _orden,
		   _cod_contrato,
		   _porc_partic_prima
	  from srectrrea
	 order by 1,2

    update rectrrea
	   set cod_contrato      = _cod_contrato,
	       porc_partic_prima = _porc_partic_prima
	 where no_tranrec        = _no_tranrec
	   and orden             = _orden;

end foreach

update rectrref
   set cod_contrato = a_cod_cont_nvo
 where cod_contrato = a_cod_cont_ant;

--Insercion en bitacora
insert into reacamco(
cod_contrato_vjo,
cod_contrato_nvo,
user_added,
date_added
)
Values(
a_cod_cont_ant,
a_cod_cont_nvo,
a_user,
current
);

end
let _error  = 0;
let _error_desc = "Proceso Completado ...";	

return _error, _error_desc;
   
END PROCEDURE;
