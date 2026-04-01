drop procedure sp_par126;

create procedure sp_par126()

delete from cobreagt
 where no_remesa = "67359"
   and renglon in (24, 56, 85, 98, 121, 142, 173, 218, 230, 248, 265, 275, 293, 502, 510, 560, 566, 655, 739,968);

delete from cobredet
 where no_remesa = "67359"
   and renglon in (24, 56, 85, 98, 121, 142, 173, 218, 230, 248, 265, 275, 293, 502, 510, 560, 566, 655, 739,968);

end procedure