-- WF - OC Despachada pendientes

-- Creado    : 23/10/2000 - Autor: Demetrio Hurtado Almanza 
-- Modificado: 24/10/2000 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - d_cheq_sp_che03_dw1 - DEIVID, S.A.

drop procedure sp_wf002;

create procedure sp_wf002()
returning integer,
          char(50),
          char(50);

define _incidente	integer;
define _cantidad	smallint;
define _taskuser	char(50);

-- deivid_tmp:tmp_oc_1 : Tiene lo pendiente en el WEB
-- deivid_tmp:tmp_oc_2 : Tiene lo pendiente en WF

{
foreach
 select incidente
   into	_incidente
   from deivid_tmp:tmp_oc_1
  group by 1
  order by 1

	select count(*)
	  into _cantidad
	  from deivid_tmp:tmp_oc_2
	 where incident = _incidente;
	 
	if _cantidad = 0 then
		
		return _incidente,
		       "No Esta en WF"
		       with resume;
		       
	end if		     

end foreach
}

foreach
 select taskuser,
        incident
   into	_taskuser,
        _incidente
   from deivid_tmp:tmp_oc_2
  group by 1, 2
  order by 1, 2

	select count(*)
	  into _cantidad
	  from deivid_tmp:tmp_oc_1
	 where incidente = _incidente;
	 
	if _cantidad = 0 then
		
		return _incidente,
			   _taskuser,
		       "No debe estar en WF"
		       with resume;
		       
	end if		     

end foreach

return 0, "", "Actualizacion Exitosa";

end procedure
