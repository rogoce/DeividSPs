    DROP PROCEDURE pd_emipomae;

    create procedure "informix".pd_emipomae(old_no_poliza char(10))
    define  errno    integer;
    define  errmsg   char(255);
    define  numrows  integer;

  {  --  Delete all children in "emiciara"
    delete from emiciara
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emicoama"
    delete from emicoama
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emicoami"
    delete from emicoami
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emidirco"
    delete from emidirco
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emipoagt"
    delete from emipoagt
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emipolde"
    delete from emipolde
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emipolim"
    delete from emipolim
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emiporec"
    delete from emiporec
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emipouni"
    delete from emipouni
    where  no_poliza = old_no_poliza;



    --  Delete all children in "endasien"
    delete from endasien
    where  no_poliza = old_no_poliza;


    --  Delete all children in "emihcmm"
    delete from emihcmm
    where  no_poliza = old_no_poliza;


    --  Delete all children in "emigloco"
    delete from emigloco
    where  no_poliza = old_no_poliza;

    --  Delete all children in "emireagm"
    delete from emireagm
    where  no_poliza = old_no_poliza;
  }

	--set debug file to "sp_emipomae.trc"; 
	--trace on;

	DELETE FROM emiciara WHERE no_poliza = old_no_poliza;
	DELETE FROM emicoama WHERE no_poliza = old_no_poliza;
	DELETE FROM emicoami WHERE no_poliza = old_no_poliza;
	DELETE FROM emidirco WHERE no_poliza = old_no_poliza;
	DELETE FROM emipoagt WHERE no_poliza = old_no_poliza;
	DELETE FROM emipolde WHERE no_poliza = old_no_poliza;
	DELETE FROM emipolim WHERE no_poliza = old_no_poliza;
	DELETE FROM emiporec WHERE no_poliza = old_no_poliza;
	DELETE FROM emirepol WHERE no_poliza = old_no_poliza;
	DELETE FROM emirenoh WHERE no_poliza = old_no_poliza;
	DELETE FROM emiprede WHERE no_poliza = old_no_poliza;
	DELETE FROM emidepen WHERE no_poliza = old_no_poliza;
	DELETE FROM emihcmd  WHERE no_poliza = old_no_poliza;
	DELETE FROM emihcmm  WHERE no_poliza = old_no_poliza;
	DELETE FROM emipode1 WHERE no_poliza = old_no_poliza;
	DELETE FROM emiglofa WHERE no_poliza = old_no_poliza;
	DELETE FROM emigloco WHERE no_poliza = old_no_poliza;
	DELETE FROM emireagf WHERE no_poliza = old_no_poliza;
	DELETE FROM emireagc WHERE no_poliza = old_no_poliza;
	DELETE FROM emireagm WHERE no_poliza = old_no_poliza;
	DELETE FROM emifafac WHERE no_poliza = old_no_poliza;
	DELETE FROM emifacon WHERE no_poliza = old_no_poliza;
	DELETE FROM emiavan  WHERE no_poliza = old_no_poliza;
	DELETE FROM emifigar WHERE no_poliza = old_no_poliza;
	DELETE FROM emifian1  WHERE no_poliza = old_no_poliza;
	DELETE FROM emipreas WHERE no_poliza = old_no_poliza;
	DELETE FROM emiunide WHERE no_poliza = old_no_poliza;
	DELETE FROM emitrand WHERE no_poliza = old_no_poliza;
	DELETE FROM emitrans WHERE no_poliza = old_no_poliza;
	DELETE FROM emiauto  WHERE no_poliza = old_no_poliza;
	DELETE FROM emicupol WHERE no_poliza = old_no_poliza;
	DELETE FROM emipoacr WHERE no_poliza = old_no_poliza;
	DELETE FROM emibenef WHERE no_poliza = old_no_poliza;
	DELETE FROM emiunire WHERE no_poliza = old_no_poliza;
	DELETE FROM emipode2 WHERE no_poliza = old_no_poliza;
	DELETE FROM emirepod WHERE no_poliza = old_no_poliza;
	DELETE FROM emicobre WHERE no_poliza = old_no_poliza;
	DELETE FROM emicobde WHERE no_poliza = old_no_poliza;
	DELETE FROM emipocob WHERE no_poliza = old_no_poliza;
	DELETE FROM eminotas WHERE no_poliza = old_no_poliza;
	DELETE FROM recrcmae WHERE no_poliza = old_no_poliza;
	DELETE FROM emipouni WHERE no_poliza = old_no_poliza;
--	DELETE FROM cobcampl WHERE no_poliza = old_no_poliza;
	DELETE FROM cobgesti WHERE no_poliza = old_no_poliza;
	DELETE FROM endedimp WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endedcob WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endmoaut WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endunide WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endmotra WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endedacr WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endcuend WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endunire WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endedde2 WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endbenef WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endeduni WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endedrec WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endcoama WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endmoage WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endeddes WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endmoase WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endcamco WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endedde1 WHERE no_poliza = old_no_poliza AND no_endoso = '00000';
	DELETE FROM endedmae WHERE no_poliza = old_no_poliza;
--	DELETE FROM endedmae WHERE no_poliza = old_no_poliza and actualizado = 0;
--	DELETE FROM emipomae WHERE no_poliza = old_no_poliza;

end procedure      