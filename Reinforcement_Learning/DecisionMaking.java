
public class DecisionMaking {
	/*
		This class provides the functions for deciding next step
	*/

	// initialize the block value at position (0,2) and position (2,1)
	static double r1 = 0;
	static double c1 = 2;

	// second block position
	static double r2 = 2;
	static double c2 = 1;

	// the constants
	static double R;  //rewards
	static double e = 0.0001;
	static double y = 0.9;

	static double d = e*(1-y)/y;

	// the probability of moving forward, left and right
	static double pForward = 0.7;
	static double pLeft = 0.2;
	static double pRight = 0.1;

	static Node[][] board;

	public static void main(String[] args)
	{	
		if (args[0].equals("p1q1"))
		{
			R = -0.04;
			valueIteration();
			print("Utility Table for r = -0.04", board);
			printDir("Policy Table for r = -0.04", board);
		}
		
		else if (args[0].equals("p1q2"))
		{
			R = -0.2;
			computeAndPrintMatrix("Matrix A for r = -0.2");
			R = -0.4;
			computeAndPrintMatrix("Matrix A for r = -0.4");			
		}
	
		else
		{
			System.out.println("choose your arg[0] as \"p1q1\" or \"p1q2\"");
		}
	}

	/** Policy Iteration
	 * Compute the utility and policy board using policy iteration
	 */
	static void policyIteration()
	{
		initializeBoard();
		print("initial Policy", board);
		boolean flag;
		int loop = 1;
		do {
			flag = false;
			Node[][] temp = duplicate(board);
			for (int i=0; i<4; i++) {
				for (int j=0; j<4; j++) {
					if (!((i==r1 && j==c1) || (i==r2 && j==c2) 
							|| (i==2 && j==3) || (i==3 && j==3)))
						updateUtil(i, j);
					if (board[i][j].getDir() != temp[i][j].getDir())
						flag = true;
				}
			}
			loop++;
		} while (flag);
	}

	/** Value Iteration
	 * Compute the utility board and policy board using value iteration
	 */
	static void valueIteration()
	{
		initializeBoard();
		double delta;
		do {
			Node[][] temp = duplicate(board);
			delta = 0;
			for (int i=0; i<4; i++) {
				for (int j=0; j<4; j++) {
					if (!((i==r1 && j==c1) || (i==r2 && j==c2) 
							|| (i==2 && j==3) || (i==3 && j==3)))
						updateUtil(i, j);
					if (Math.abs(board[i][j].getUtil() - temp[i][j].getUtil()) > delta)
						delta = Math.abs(board[i][j].getUtil() - temp[i][j].getUtil());					
				}
			}
		} while (delta >= d);
	}

	/** Update utility and policy
	 * update the utility and policy at position (r, c)
	 * @param r : row of board
	 * @param c : column of board
	 */
	static void updateUtil(int r, int c)
	{
		double max = -1000;
		for (int dir=0; dir<4; dir++)
		{
			double temp = 0;
			// north
			if (dir == 0) {
				double p = 0;
				if (!isForbid(r-1, c)) {
					temp += board[r-1][c].getUtil() * pForward;
					p += pForward;
				}

				if (!isForbid(r, c+1)) {
					temp += board[r][c+1].getUtil() * pRight;
					p += pRight;
				}

				if (!isForbid(r, c-1)) {
					temp += board[r][c-1].getUtil() * pLeft;
					p += pLeft;
				}

				temp += board[r][c].getUtil() * (1-p);
				if (temp > max) {					
					max = temp;
					board[r][c].setDir(0);
				}
			}

			// east
			else if (dir == 1) {
				double p = 0;
				if (!isForbid(r, c+1)) {
					temp += board[r][c+1].getUtil() * pForward;
					p += pForward;
				}

				if (!isForbid(r-1, c)) {
					temp += board[r-1][c].getUtil() * pLeft;
					p += pLeft;
				}

				if (!isForbid(r+1, c)) {
					temp += board[r+1][c].getUtil() * pRight;
					p += pRight;
				}

				temp += board[r][c].getUtil() * (1-p);
				if (temp > max) {
					max = temp;
					board[r][c].setDir(1);
				}
			}

			// south
			else if (dir == 2) {
				double p = 0;
				if (!isForbid(r+1, c)) {
					temp += board[r+1][c].getUtil() * pForward;
					p += pForward;
				}

				if (!isForbid(r, c+1)) {
					temp += board[r][c+1].getUtil() * pLeft;
					p += pLeft;
				}

				if (!isForbid(r, c-1)) {
					temp += board[r][c-1].getUtil() * pRight;
					p += pRight;
				}

				temp += board[r][c].getUtil() * (1-p);
				if (temp > max) {
					max = temp;
					board[r][c].setDir(2);
				}
			}

			// west
			else {
				double p = 0;
				if (!isForbid(r, c-1)) {
					temp += board[r][c-1].getUtil() * pForward;
					p += pForward;
				}

				if (!isForbid(r+1, c)) {
					temp += board[r+1][c].getUtil() * pLeft;
					p += pLeft;
				}

				if (!isForbid(r-1, c)) {
					temp += board[r-1][c].getUtil() * pRight;
					p += pRight;
				}

				temp += board[r][c].getUtil() * (1-p);
				if (temp > max) {
					max = temp;
					board[r][c].setDir(3);
				}
			}
		}
		board[r][c].setUtil(R + y*max);
	}
	
	/** Check if the board element board[r][c] is inside the board and its
	 * utility values can be updated
	 * @param r : row of the board
	 * @param c : column of the board
	 * @return : return true if the position is outside board or if position
	 * can't be updated
	 */
	static boolean isForbid(int r, int c)
	{

		if (r<0 || r>3 || c<0 || c>3 
				|| (r == r1 && c == c1) || (r == r2 && c == c2))

			return true;
		return false;

	}
	
	/** Duplicate the Board
	 * create a new board that contains the same elements as the old one
	 * @param board : the board to be duplicated
	 * @return a new board
	 */
	static Node[][] duplicate(Node[][] board)
	{
		int len = board[0].length;
		Node[][] temp = new Node[len][len];
		for (int i=0; i<len; i++) {
			for (int j=0; j<len; j++) {
				temp[i][j] = new Node(board[i][j].getUtil(), board[i][j].getDir());
			}
		}
		return temp;
	}

	/** Initialize a new board
	 * initialize a new board that contains the position of blockage, 
	 * reward and punishment
	 */
	static void initializeBoard()
	{
		board = new Node[4][4];
		for (int i=0; i<4; i++) {
			for (int j=0; j<4; j++) {
				board[i][j] = new Node(0);
			}
		}
		board[2][3].setUtil(-1);
		board[3][3].setUtil(1);
	}
	/** Print the utility Board
	 * print the utilities of all the elements in the board
	 * @param str : the string to be displayed on the board
	 * @param bd : the board to be printed
	 */
	static void print(String str, Node[][] bd)
	{
		System.out.println("========<" + str + ">========" );
		for (int i=0; i<4; i++) {
			for (int j=0; j<4; j++) {
				System.out.format("%.4f ", bd[i][j].getUtil());
			}
			System.out.println();
		}
		System.out.println("============================");
	}
	
	/** Print the Policy board
	 * print the policy of all the elements in the board
	 * @param str : the string to be displayed on the board
	 * @param bd the board to be printed
	 */
	static void printDir(String str, Node[][] bd)
	{
		System.out.println("========<" + str + ">========" );
		for (int i=0; i<4; i++) {
			for (int j=0; j<4; j++) {
				String dir = "";
				if (i==r1 && j==c1)
					dir = "X";
				else if (i==r2 && j==c2)
					dir = "X";
				else if (i==3 && j==3)
					dir = "1";
				else if (i==2 && j==3)
					dir = "-1";
				else if (bd[i][j].getDir() == 0)
					dir = "N";
				else if (bd[i][j].getDir() == 1)
					dir = "E";
				else if (bd[i][j].getDir() == 2)
					dir = "S";
				else 
					dir = "W";
				
				System.out.print(dir + " ");
			}
			System.out.println();
		}
		System.out.println("============================");
	}
	
	/** Compute the matrix Element of M
	 * u = r + Mu
	 */
	static void computeAndPrintMatrix(String str)
	{
		initializeBoard();
		int len = board.length;
		double[][] matrix = new double[14][14];
		for (int c=0; c<len; c++)
		{
			for (int r=len-1; r>=0; r--)
			{
				if ((r==r1 && c==c1) || (r==r2 && c==c2) 
						|| (r==2 && c==3) || (r==3 && c==3))
					continue;

				else 
				{
					double p = 1;
					// down
					if (!isForbid(r+1,c))
					{
						matrix[colNumber(r,c)][colNumber(r+1,c)] = 0.7;
						p -= 0.7;
					}
					
					// east
					if (!isForbid(r, c+1))
					{
						matrix[colNumber(r,c)][colNumber(r,c+1)] = 0.2;
						p -= 0.2;
					}
					
					// west
					if (!isForbid(r, c-1))
					{
						matrix[colNumber(r,c)][colNumber(r,c-1)] = 0.1;
						p -= 0.1;
					}
					matrix[colNumber(r,c)][colNumber(r,c)] = p;
				}
			}
		}
		printMatrix(str, matrix);
		
		double[] b = new double[matrix.length];
		for (int i=0; i<matrix.length; i++)
		{
			if (i == 10)
				b[i] = 1;
			else if (i == 11)
				b[i] = -1;
			else
				b[i] = R;
		}
		printV(b);
	}
	
	
	/** print the elements of the matrix
	 * @param matrix : the matrix
	 */
	static void printMatrix(String str, double[][] matrix)
	{
		System.out.println("=====<" + str + ">=====");
		int len = matrix.length;
		for (int i=0; i<len; i++)
		{
			for (int j=0; j<len; j++)
			{
				System.out.format("%.1f ", matrix[i][j]);
			}
			System.out.println();
		}
		System.out.println("--------------------");
	}
	
	/** Print the vectors
	 */
	static void printV(double[] v)
	{
		System.out.print("b = (");
		int len = v.length;
		for (int i=0; i<len; i++)
		{
			System.out.format("%.2f ", v[i]);
		}
		System.out.println(")");
	}
	
	/** return the column number of matrix M give row and column number of board
	 * @param r : row number of board
	 * @param c : column number of board
	 * @return
	 */
	static int colNumber(int r, int c)
	{
		if (c == 0)
		{
			switch (r) {
			case 0 : return 3;
			case 1 : return 2;
			case 2 : return 1;
			case 3 : return 0;
			}
		}
		else if (c == 1)
		{
			switch (r) {
			case 0 : return 6;
			case 1 : return 5;
			case 2 : return -1;
			case 3 : return 4; 
			}
		}
		else if (c == 2)
		{
			switch (r) {
			case 0 : return -1;
			case 1 : return 9;
			case 2 : return 8;
			case 3 : return 7; 
			}
		}
		else if (c == 3)
		{
			switch (r) {
			case 0 : return 13;
			case 1 : return 12;
			case 2 : return 11;
			case 3 : return 10; 
			}
		}
		return -1;
	}

}
