-- copia de sp_sis61b_am para no modificar ese sp. 
--Creado por manuel reyes

drop procedure sp_sis61b_lote;
create procedure sp_sis61b_lote(a_no_poliza char(10))
returning integer,char(10);
--) returning char(10),char(20);

define _poliza 		char(20);
define _no_poliza 	char(10);
define _error		integer;
define _existe		integer;
define _fecha_hoy 	date;

begin
on exception set _error
	return _error,_no_poliza;
end exception

let _fecha_hoy = sp_sis26();

--set debug file to "sp_sis61b.trc";
--trace on;

foreach
	select no_poliza,
		   no_documento
	  into _no_poliza,
		   _poliza
	  from emipomae
	 where actualizado = 0 
	 and no_poliza in 
	 (	
'3254801',	
'3254867',	
'3254864',	
'3254882',	
'3254890'
	)

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
	delete from deivid_integrapol where no_poliza = _no_poliza and no_endoso = '00000';
end foreach
end

return 0,_no_poliza;

end procedure;