-- Modificado Armando Moreno	12/10/2004

--Procedimiento para borrar los endosos y polizas no act. mayores de 90 dias.
--Ademas, actualiza los endosos y las polizas no act. con periodo menor al cerrado con el periodo nvo.
--lo ultimo se identifica con parametro a_flag = 1
--Este procedure es llamado desde el programa cierre de prod.

drop procedure ap_reversa_renov_aut;
create procedure ap_reversa_renov_aut()
returning integer,char(10);
--) returning char(10),char(20);

define _poliza 		  char(20);
define _no_poliza 	  char(10);
define _error		  integer;
define _existe		  integer;
define _fecha_hoy 	  date;
define _no_motor      char(30);
define _nuevo         smallint;
define _no_poliza_ant char(10);

begin
on exception set _error
	return _error,_no_poliza;
end exception

let _fecha_hoy = sp_sis26();

set debug file to "ap_reversa_renov_aut.trc";
trace on;

foreach
	select distinct a.no_poliza_r,
	       a.no_poliza_ant
	  into _no_poliza,
	       _no_poliza_ant
	from prdpreren a, emipomae d
	where a.no_poliza_r = d.no_poliza
	and a.periodo = '2025-12' and tipo_ren = 2
    and a.procesado = 1	
	and d.actualizado = 0
    and a.no_documento  in (
'0224-01404-03',
'0224-01433-10',
'0224-01495-03',
'0224-01480-05',
'0224-01486-10',
'0223-01914-03',
'0223-00694-07',
'0223-01950-03',
'0223-01963-03',
'0223-01467-10',
'0223-01498-10',
'0221-00582-07',
'0221-01571-03',
'0221-00505-11',
'0222-02166-03',
'0223-09610-09',
'0223-10030-09',
'0223-03983-01',
'0223-04017-01',
'0223-10349-09',
'0223-10452-09',
'0222-01027-10',
'0222-01060-10',
'0223-01400-05',
'0223-00803-02',
'0222-01086-10',
'0223-00743-07',
'0223-10262-09',
'0221-00755-10',
'0222-07304-09',
'0223-00805-02',
'0224-08371-09',
'0224-08405-09',
'0224-05876-01',
'0224-08477-09',
'0224-08499-09',
'0224-00715-07',
'0224-00601-11',
'0224-00597-02',
'0224-08541-09',
'0224-00722-07',
'0224-05923-01',
'0224-08610-09',
'0224-03019-01',
'0224-08701-09',
'0224-03026-01',
'0224-08724-09',
'0224-01479-05',
'0224-03867-01'
    )
	
	let _nuevo = 0;
	
	foreach
		select no_motor,
			   nuevo
		  into _no_motor,
			   _nuevo
		from prdpreren
	   where no_poliza_r = _no_poliza

		if _nuevo = 1 then
			update emivehic set nuevo = 1 where no_motor = _no_motor;
		end if
	end foreach	

	delete from emiciara where no_poliza = _no_poliza;
	delete from emicoama where no_poliza = _no_poliza;
	delete from emicoami where no_poliza = _no_poliza;
	delete from emidirco where no_poliza = _no_poliza;
	delete from emipoagt where no_poliza = _no_poliza;
	delete from emipolde where no_poliza = _no_poliza;
	delete from emipolim where no_poliza = _no_poliza;
	delete from emiporec where no_poliza = _no_poliza;
	delete from emirepol where no_poliza = _no_poliza;
	delete from eminotas where no_poliza = _no_poliza;
	delete from emirenoh where no_poliza = _no_poliza;
	delete from emiprede where no_poliza = _no_poliza;
	delete from emidepen where no_poliza = _no_poliza;
	delete from emihcmd  where no_poliza = _no_poliza;
	delete from emihcmm  where no_poliza = _no_poliza;
	delete from emipode1 where no_poliza = _no_poliza;
	delete from emiglofa where no_poliza = _no_poliza;
	delete from emigloco where no_poliza = _no_poliza;
	delete from emireagf where no_poliza = _no_poliza;
	delete from emireagc where no_poliza = _no_poliza;
	delete from emireagm where no_poliza = _no_poliza;
	delete from emifafac where no_poliza = _no_poliza;
	delete from emifacon where no_poliza = _no_poliza;
	delete from emiavan  where no_poliza = _no_poliza;
	delete from emifigar where no_poliza = _no_poliza;
	delete from emifian1  where no_poliza = _no_poliza;
	delete from emipreas where no_poliza = _no_poliza;
	delete from emiunide where no_poliza = _no_poliza;
	delete from emitrand where no_poliza = _no_poliza;
	delete from emitrans where no_poliza = _no_poliza;
	delete from emiauto  where no_poliza = _no_poliza;
	delete from emicupol where no_poliza = _no_poliza;
	delete from emipoacr where no_poliza = _no_poliza;
	delete from emibenef where no_poliza = _no_poliza;
	delete from emiunire where no_poliza = _no_poliza;
	delete from emipode2 where no_poliza = _no_poliza;
	delete from emirepod where no_poliza = _no_poliza;
	delete from emicobre where no_poliza = _no_poliza;
	delete from emicobde where no_poliza = _no_poliza;
	delete from emipocob where no_poliza = _no_poliza;
	delete from recrcmae where no_poliza = _no_poliza;
	delete from emipouni where no_poliza = _no_poliza;
--	delete from cobcampl where no_poliza = _no_poliza;
	delete from cobgesti where no_poliza = _no_poliza;
	delete from endedimp where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endcobde where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endcobre where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endedcob where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endmoaut where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endunide where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endmotra where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endedacr where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endcuend where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endunire where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endedde2 where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endbenef where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endeduni where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endedrec where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endcoama where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endmoage where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endeddes where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endmoase where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endcamco where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endedde1 where no_poliza = _no_poliza and no_endoso = '00000';
	delete from endedmae where no_poliza = _no_poliza and actualizado = 0;
	delete from endedhis where no_poliza = _no_poliza and actualizado = 0;
	delete from emipomae where no_poliza = _no_poliza;	
	
	update emipomae set renovada = 0 where no_poliza = _no_poliza_ant;
	
	update prdpreren
	   set procesado = 9,
	       desc_error = 'Excluido por el tecnico',
		   no_poliza_r = null,
		   prima_resultado = 0
	 where no_poliza_r = _no_poliza;

return 0,_no_poliza with resume;
end foreach
end

--return 0,_no_poliza;

end procedure;