
drop procedure sp_sis200a;

create procedure "informix".sp_sis200a()--, a_no_unidad char(5))
returning char(10),integer,char(3),char(5),dec(16,2);

define _mensaje			char(250);
define _no_remesa1		char(10);
define _no_remesa		char(10);
define _cod_contrato	char(5);
define _cod_cober_reas	char(3);
define _porc_proporcion	dec(16,2);
define _error_isam		integer;
define _renglon			integer;
define _renglon1		integer;
define _error			integer;

set isolation to dirty read;

--set debug file to "sp_sis200.trc";
--trace on;

begin

{on exception set _error,_error_isam,_mensaje
	--rollback work;
 	--return _error,_mensaje;
end exception}

foreach
	select r.no_remesa,r.renglon,sum(porc_proporcion * porc_partic_prima/100)
	  into _no_remesa,_renglon,_porc_proporcion
	  from cobredet d, cobreaco r
	 where d.no_remesa = r.no_remesa
	   and d.renglon = r.renglon
	   and d.no_recibo in ('839761','897207','906045','906052','906061','906138','906151','906167','906372','971786','974046','985095','990245','990389','999636','1000098','1000135','1000202','1000382',
						   '1000952','1002546','1006074','1006074','1006191','1008192','1008303','1008308','1015080','1015157','1018568','1018753','1018875','1019073','1019258','1019426','1023109',
						   '1023363','1023537','1023544','1023545','1023674','1024144','1024348','1024728','1025198','1025384','1025384','1025442','1033550','1033758','1033843','1034067','1034200',
						   '1034217','1034405','1039440','1039775','14123045','14123054','021-44679','021-44781','021-44861','021-44861','021-44861','021-44861','021-44861','021-44861','021-44861',
						   '021-44861','021-44861','021-44861','021-44861','021-44861','021-44861','021-44861','021-44861','021-45097','021-45097','021-45097','021-45097','021-45097','021-45097',
						   '021-45097','021-45097','021-45097','021-45097','021-45097','021-45097','021-45097','021-45097','021-45097','021-45097','021-45097','021-45097','021-45097','029-01148',
						   'ACH011014','ACH011014','ACH011014','ACH011014','ACH160914','ACH160914','ACH160914','ACH160914','ACH160914','BG010914','BG020914','BG020914','BG030914','BG050914','BG140514',
						   'BG140514','BG190914','BG190914','BG270614','BG270614','BG270814','BG270814','BG290714','BG290714','BG300714','CD500914','CD500914','CKDV905671','CONT020514','CONT020514',
						   'CONT020514','GB020914','GB100914','REY130914','TCR050914','TCR220914','VC150914','VC150914')
	 group by 1,2
	 having sum(porc_proporcion * porc_partic_prima/100) <> 100

	foreach
		select no_remesa,renglon,cod_cober_reas,cod_contrato
		  into _no_remesa1,_renglon1,_cod_cober_reas,_cod_contrato
		  from cobreaco
		 where no_remesa = _no_remesa
		   and renglon = _renglon
		
		return _no_remesa1,_renglon1,_cod_cober_reas,_cod_contrato,_porc_proporcion with resume;
	end foreach
end foreach
end
end procedure;